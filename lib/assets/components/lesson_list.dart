import 'package:arabella/assets/components/paging_scroll_physics.dart';
import 'package:arabella/assets/models/chapter_model.dart';
import 'package:arabella/assets/models/providers/covered_material_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/providers/chapters_provider.dart';
import '../models/providers/scroll_offset_provider.dart';

class LessonList extends StatefulWidget {
  const LessonList({Key? key, required this.chapter}) : super(key: key);

  final ChapterModel chapter;

  @override
  State<LessonList> createState() => _LessonListState();
}

class _LessonListState extends State<LessonList> with WidgetsBindingObserver {
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    initializePageController();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeMetrics() {
    initializePageController();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScrollOffsetProvider>(
      builder: (context, scrollOffset, child) {
        return SizedBox(
          height: 200,
          child: ListView.builder(
            controller: pageController,
            scrollDirection: Axis.horizontal,
            physics: const PagingScrollPhysics(itemDimension: 250),
            itemCount: widget.chapter.lessons.length,
            itemBuilder: (context, i) {
              String lesson = widget.chapter.lessons[i];
              return Builder(
                builder: (BuildContext context) {
                  return SizedBox(
                    width: 250,
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          fit: StackFit.passthrough,
                          children: <Widget>[
                            Hero(
                              tag: 'lesson_image $lesson',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  ChaptersProvider.getImageFromLesson(
                                    widget.chapter.chapterName,
                                    lesson,
                                  ),
                                  fit: BoxFit.cover,
                                  alignment: Alignment(
                                      -(scrollOffset.scrollOffset[widget
                                                      .chapter.chapterName] ??
                                                  0)
                                              .abs() +
                                          i,
                                      0),
                                ),
                              ),
                            ),
                            Consumer<CoveredMaterialProvider>(
                              builder: (context, coveredMaterial, child) {
                                return (isLessonFinished(
                                        coveredMaterial, lesson))
                                    ? Positioned.directional(
                                        textDirection:
                                            Directionality.of(context),
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
        );
      },
    );
  }

  void initializePageController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double width = MediaQuery.of(context).size.width;

      pageController.dispose();
      pageController = PageController(viewportFraction: 255 / width);
      pageController.addListener(
        () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (pageController.page != null) {
              context.read<ScrollOffsetProvider>().setScrollOffset(
                  widget.chapter.chapterName, pageController.page!);
            }
          });
        },
      );
      setState(() {});
    });
  }

  bool isLessonFinished(
      CoveredMaterialProvider coveredMaterial, String lesson) {
    return coveredMaterial.isLessonFinished(widget.chapter.chapterName, lesson);
  }
}
