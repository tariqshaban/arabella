import 'package:arabella/assets/helpers/dynamic_tr.dart';
import 'package:flutter/material.dart';

import '../enums/map_annotation_type.dart';

class PointsOfInterestInfo extends StatefulWidget {
  const PointsOfInterestInfo({
    Key? key,
    required this.mapAnnotationType,
    required this.chapterName,
    required this.lessonName,
    required this.pointOfInterestName,
  }) : super(key: key);

  final MapAnnotationType mapAnnotationType;
  final String chapterName;
  final String lessonName;
  final String pointOfInterestName;

  @override
  State<PointsOfInterestInfo> createState() => _PointsOfInterestInfoState();
}

class _PointsOfInterestInfoState extends State<PointsOfInterestInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          horizontalTitleGap: 0,
          leading: Icon(getMapAnnotationIcon()),
          title: Text('points_of_interest.${widget.pointOfInterestName}.title')
              .dtr(context),
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 30),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  'points_of_interest.${widget.pointOfInterestName}.content',
                ).dtr(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData getMapAnnotationIcon() {
    if (widget.mapAnnotationType == MapAnnotationType.marker) {
      return Icons.location_pin;
    } else if (widget.mapAnnotationType == MapAnnotationType.polyline) {
      return Icons.polyline;
    } else {
      return Icons.dashboard;
    }
  }
}
