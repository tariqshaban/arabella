import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:arabella/assets/components/point_of_interest_info.dart';
import 'package:arabella/assets/models/providers/maps_icon_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

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
  late dynamic manifest;
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
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(31.4645395, 37.022226),
                      zoom: 6.8,
                    ),
                    minMaxZoomPreference: const MinMaxZoomPreference(null, 18),
                    mapToolbarEnabled: false,
                    markers: markers,
                    polylines: polylines,
                    polygons: polygons,
                    buildingsEnabled: false,
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

                      controller.animateCamera(
                        CameraUpdate.newLatLngBounds(
                            getInitialCameraPosition(), 50),
                      );
                    });
              }
              return const SizedBox();
            },
            future: decodeMapsManifest(),
          ),
        ),
      ),
    );
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

    // Delay google maps widget build, since it slows the device, and causes to crash if rebuilt too often
    await Future.delayed(const Duration(seconds: 1));

    return;
  }

  LatLngBounds getInitialCameraPosition() {
    List<LatLng> points = [];

    for (dynamic pointOfInterest in manifest['points_of_interest']) {
      for (dynamic latLng in pointOfInterest['points']) {
        points.add(
          LatLng(
            latLng['lat'],
            latLng['lng'],
          ),
        );
      }
    }

    return _getPointsCenter(points);
  }

  void assignMarkers() async {
    int counter = 0;
    for (dynamic pointOfInterest in manifest['points_of_interest']) {
      if (pointOfInterest['type'] != 'point') {
        continue;
      }

      BitmapDescriptor icon = context.read<MapsIconProvider>().icon;

      markers.add(
        Marker(
          markerId: MarkerId('point ${counter++}'),
          position: LatLng(
            pointOfInterest['points'][0]['lat'],
            pointOfInterest['points'][0]['lng'],
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
              CameraUpdate.newLatLngBounds(_getPointsCenter(points), 50),
            );
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
              CameraUpdate.newLatLngBounds(_getPointsCenter(points), 50),
            );
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
