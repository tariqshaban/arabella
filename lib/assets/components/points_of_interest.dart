import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:arabella/assets/components/point_of_interest_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;

import '../enums/map_annotation_type.dart';

class PointsOfInterest extends StatefulWidget {
  const PointsOfInterest({
    Key? key,
    required this.chapterName,
    required this.lessonName,
    this.padding = EdgeInsets.zero,
    this.height = 200,
    this.borderRadius = BorderRadius.zero,
  }) : super(key: key);

  final String chapterName;
  final String lessonName;
  final EdgeInsetsGeometry padding;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<PointsOfInterest> createState() => _PointsOfInterestState();
}

class _PointsOfInterestState extends State<PointsOfInterest> {
  late GoogleMapController controller;
  late dynamic manifest = decodeMapsManifest();
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Set<Polygon> polygons = {};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: SizedBox(
          height: widget.height,
          child: FutureBuilder(
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return GoogleMap(
                    gestureRecognizers: {
                      Factory<EagerGestureRecognizer>(
                          () => EagerGestureRecognizer())
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        manifest['initial_position']['lat'],
                        manifest['initial_position']['lng'],
                      ),
                      zoom: manifest['initial_position']['zoom'],
                    ),
                    mapToolbarEnabled: false,
                    markers: markers,
                    polylines: polylines,
                    polygons: polygons,
                    zoomControlsEnabled: false,
                    onMapCreated: (GoogleMapController controller) async {
                      this.controller = controller;

                      if (await AdaptiveTheme.getThemeMode() ==
                          AdaptiveThemeMode.dark) {
                        controller.setMapStyle(await rootBundle
                            .loadString('assets/maps/dark_theme.json'));
                      } else {
                        controller.setMapStyle(null);
                      }
                    });
              }
              return const SizedBox();
            },
            future: manifest,
          ),
        ),
      ),
    );
  }

  static Future<Uint8List> _getBytesFromAsset(
      String path, int width, Color color) async {
    ByteData byteData = await rootBundle.load(path);
    Uint8List int8List = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    List<int> doneListInt = int8List.cast<int>();

    img.Image outputImage = img.decodePng(doneListInt)!;

    img.colorOffset(
      outputImage,
      red: color.red,
      green: color.green,
      blue: color.blue,
    );

    outputImage = img.copyResize(outputImage, width: width);

    return Uint8List.fromList(img.encodePng(outputImage));

    // ByteData data = await rootBundle.load(path);
    // ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
    //     targetWidth: width);
    // ui.FrameInfo fi = await codec.getNextFrame();
    //
    // return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
    //     .buffer
    //     .asUint8List();
  }

  dynamic decodeMapsManifest() async {
    String chapterName =
        widget.chapterName.substring(widget.chapterName.indexOf('-') + 1);
    String lessonName = widget.lessonName.substring(
        widget.lessonName.indexOf('-') + 1, widget.lessonName.indexOf('.'));

    String file = await rootBundle.loadString('assets/maps/maps_manifest.json');
    manifest = json.decode(file)[chapterName][lessonName];

    assignMarkers();
    assignPolylines();
    assignPolygons();

    return;
  }

  void assignMarkers() async {
    Color primaryColor = Theme.of(context).colorScheme.primary;
    int counter = 0;
    for (dynamic pointOfInterest in manifest['points_of_interest']) {
      if (pointOfInterest['type'] != 'point') {
        continue;
      }

      BitmapDescriptor icon = BitmapDescriptor.fromBytes(
        await _getBytesFromAsset(
          'assets/images/markers/marker.png',
          (min(MediaQuery.of(context).size.height,
                      MediaQuery.of(context).size.width) /
                  6)
              .round(),
          primaryColor,
        ),
      );

      markers.add(
        Marker(
          markerId: MarkerId('point ${counter++}'),
          position: LatLng(
            pointOfInterest['lat'],
            pointOfInterest['lng'],
          ),
          icon: icon,
          onTap: () {
            showSheet(pointOfInterest['name'], MapAnnotationType.marker);
          },
        ),
      );
    }
  }

  Future<void> assignPolylines() async {
    int counter = 0;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    for (dynamic pointOfInterest in manifest['points_of_interest']) {
      if (pointOfInterest['type'] != 'polyline') {
        continue;
      }

      List<LatLng> points = [];
      for (dynamic position in pointOfInterest['points']) {
        points.add(LatLng(position['lat'], position['lng']));
      }

      polylines.add(
        Polyline(
            polylineId: PolylineId('polyline $counter - border'),
            consumeTapEvents: true,
            points: points,
            color:
                (await AdaptiveTheme.getThemeMode() == AdaptiveThemeMode.dark)
                    ? Colors.white
                    : Colors.black,
            width: 4),
      );

      polylines.add(
        Polyline(
          polylineId: PolylineId('polyline ${counter++}'),
          consumeTapEvents: true,
          points: points,
          color: primaryColor,
          width: 3,
          onTap: () {
            controller.animateCamera(
                CameraUpdate.newLatLngBounds(_getPointsCenter(points), 50));
            showSheet(pointOfInterest['name'], MapAnnotationType.polyline);
          },
        ),
      );
    }
  }

  Future<void> assignPolygons() async {
    int counter = 0;
    Color primaryColor = Theme.of(context).colorScheme.primary;
    for (dynamic pointOfInterest in manifest['points_of_interest']) {
      if (pointOfInterest['type'] != 'polygon') {
        continue;
      }

      List<LatLng> points = [];
      for (dynamic position in pointOfInterest['points']) {
        points.add(LatLng(position['lat'], position['lng']));
      }

      polygons.add(
        Polygon(
          polygonId: PolygonId('polyline $counter - border'),
          consumeTapEvents: true,
          points: points,
          fillColor: primaryColor.withOpacity(0.5),
          strokeColor:
              (await AdaptiveTheme.getThemeMode() == AdaptiveThemeMode.dark)
                  ? Colors.white
                  : Colors.black,
          strokeWidth: 1,
          onTap: () {
            controller.animateCamera(
                CameraUpdate.newLatLngBounds(_getPointsCenter(points), 50));
            showSheet(pointOfInterest['name'], MapAnnotationType.polygon);
          },
        ),
      );
    }
  }

  LatLngBounds _getPointsCenter(List<LatLng> points) {
    double minLat = points
        .reduce((currentPoint, nextPoint) =>
            currentPoint.latitude > nextPoint.latitude
                ? nextPoint
                : currentPoint)
        .latitude;
    double minLng = points
        .reduce((currentPoint, nextPoint) =>
            currentPoint.longitude > nextPoint.longitude
                ? nextPoint
                : currentPoint)
        .longitude;
    double maxLat = points
        .reduce((currentPoint, nextPoint) =>
            currentPoint.latitude > nextPoint.latitude
                ? currentPoint
                : nextPoint)
        .latitude;
    double maxLng = points
        .reduce((currentPoint, nextPoint) =>
            currentPoint.longitude > nextPoint.longitude
                ? currentPoint
                : nextPoint)
        .longitude;

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void showSheet(String name, MapAnnotationType mapAnnotationType) {
    String chapterName =
        widget.chapterName.substring(widget.chapterName.indexOf('-') + 1);
    String lessonName = widget.lessonName.substring(
        widget.lessonName.indexOf('-') + 1, widget.lessonName.indexOf('.'));

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (context) => PointsOfInterestInfo(
        mapAnnotationType: mapAnnotationType,
        chapterName: chapterName,
        lessonName: lessonName,
        pointOfInterestName: name,
      ),
    );
  }
}
