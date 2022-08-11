import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
      body: LessonListVertical(chapter: widget.chapter),
    );
  }
}
