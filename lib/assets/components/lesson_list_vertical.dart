import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chapter_model.dart';
import '../models/providers/chapters_provider.dart';
import '../models/providers/covered_material_provider.dart';

class LessonListVertical extends StatefulWidget {
  const LessonListVertical({Key? key, required this.chapter}) : super(key: key);

  final ChapterModel chapter;

  @override
  State<LessonListVertical> createState() => _LessonListVerticalState();
}

class _LessonListVerticalState extends State<LessonListVertical> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.chapter.lessons.length,
      itemBuilder: (context, i) {
        String lesson = widget.chapter.lessons[i];
        return Builder(
          builder: (BuildContext context) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Card(
                margin: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
                elevation: 5,
                shadowColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 150,
                          height: 100,
                          child: Hero(
                            tag: 'lesson_image $lesson',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                ChaptersProvider.getImageFromLesson(
                                  widget.chapter.chapterName,
                                  lesson,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 25),
                        Expanded(
                          child: Text(
                            ChaptersProvider.getLessonTranslatableName(
                                    widget.chapter.chapterName, lesson)
                                .tr(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 20),
                          child: Icon(
                            Icons.navigate_next,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      ],
                    ),
                    Consumer<CoveredMaterialProvider>(
                      builder: (context, coveredMaterial, child) {
                        return (isLessonFinished(coveredMaterial, lesson))
                            ? Positioned.directional(
                                textDirection: Directionality.of(context),
                                top: 5,
                                start: 5,
                                child: Hero(
                                  tag: 'lesson_complete $lesson',
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
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
                    SizedBox(
                      height: 100,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool isLessonFinished(
      CoveredMaterialProvider coveredMaterial, String lesson) {
    return coveredMaterial.isLessonFinished(widget.chapter.chapterName, lesson);
  }
}
