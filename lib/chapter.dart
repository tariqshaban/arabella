import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'assets/components/learning_description.dart';
import 'assets/components/learning_outcomes.dart';
import 'assets/components/learning_progress.dart';
import 'assets/components/lesson_list_vertical.dart';
import 'assets/models/chapter_model.dart';
import 'assets/models/providers/chapters_provider.dart';

class Chapter extends StatefulWidget {
  const Chapter({Key? key, required this.chapter}) : super(key: key);

  final ChapterModel chapter;

  @override
  State<Chapter> createState() => _ChapterState();
}

class _ChapterState extends State<Chapter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ChaptersProvider.getChapterTranslatableName(
                widget.chapter.chapterName))
            .tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          shrinkWrap: true,
          children: [
            LearningProgress(chapter: widget.chapter),
            LayoutBuilder(
              builder: (context, constraints) {
                return constraints.maxWidth > 600
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                              child:
                                  LearningDescription(chapter: widget.chapter)),
                          const SizedBox(width: 20),
                          Flexible(
                              child: LearningOutcomes(chapter: widget.chapter)),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LearningDescription(chapter: widget.chapter),
                          LearningOutcomes(chapter: widget.chapter),
                        ],
                      );
              },
            ),
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Divider(thickness: 2),
            ),
            LessonListVertical(chapter: widget.chapter),
          ],
        ),
      ),
    );
  }
}
