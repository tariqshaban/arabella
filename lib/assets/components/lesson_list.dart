import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chapter_model.dart';
import '../models/providers/chapters_provider.dart';
import '../models/providers/covered_material_provider.dart';
import 'paging_scroll_physics.dart';
import 'parallax.dart';

class LessonList extends StatefulWidget {
  const LessonList({Key? key, required this.chapter}) : super(key: key);

  final ChapterModel chapter;

  @override
  State<LessonList> createState() => _LessonListState();
}

class _LessonListState extends State<LessonList> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
          },
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const PagingScrollPhysics(itemDimension: 250),
          itemCount: widget.chapter.lessons.length,
          itemBuilder: (context, i) {
            String lesson = widget.chapter.lessons[i];
            return Builder(
              builder: (BuildContext context) {
                final GlobalKey backgroundImageKey = GlobalKey();
                return SizedBox(
                  width: 250,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: <Widget>[
                          Hero(
                            tag: 'lesson_image $lesson',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Flow(
                                delegate: ParallaxFlowDelegate(
                                  scrollable: Scrollable.of(context)!,
                                  listItemContext: context,
                                  backgroundImageKey: backgroundImageKey,
                                ),
                                children: [
                                  Image.asset(
                                    key: backgroundImageKey,
                                    ChaptersProvider.getImageFromLesson(
                                      widget.chapter.chapterName,
                                      lesson,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Consumer<CoveredMaterialProvider>(
                            builder: (context, coveredMaterial, child) {
                              return (isLessonFinished(coveredMaterial, lesson))
                                  ? Positioned.directional(
                                      textDirection: Directionality.of(context),
                                      top: 5,
                                      end: 5,
                                      child: Hero(
                                        tag: 'lesson_complete $lesson',
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            color: Colors.green,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox();
                            },
                          ),
                          Positioned.directional(
                            textDirection: Directionality.of(context),
                            start: 0,
                            end: 0,
                            bottom: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 0, 0, 0),
                                    Color.fromARGB(0, 0, 0, 0)
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                              child: Text(
                                ChaptersProvider.getLessonTranslatableName(
                                        widget.chapter.chapterName, lesson)
                                    .tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/lesson',
                                    arguments: {
                                      'chapter': widget.chapter,
                                      'lesson': lesson
                                    },
                                  );
                                },
                                borderRadius: BorderRadius.circular(15),
                                splashColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  bool isLessonFinished(
      CoveredMaterialProvider coveredMaterial, String lesson) {
    return coveredMaterial.isLessonFinished(widget.chapter.chapterName, lesson);
  }
}
