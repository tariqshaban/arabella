import 'package:easy_localization/easy_localization.dart';
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
    return DraggableScrollableSheet(
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Column(
          children: <Widget>[
            ListTile(
              leading: Icon(getMapAnnotationIcon()),
              title: Text(
                      'chapters.${widget.chapterName}.lessons.${widget.lessonName}.points_of_interest.${widget.pointOfInterestName}.title')
                  .tr(),
            ),
            Flexible(
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (notification) {
                  notification.disallowIndicator();
                  return true;
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        'chapters.${widget.chapterName}.lessons.${widget.lessonName}.points_of_interest.${widget.pointOfInterestName}.content',
                      ).tr(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
