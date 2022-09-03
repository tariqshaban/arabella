import 'package:arabella/assets/helpers/dynamic_tr.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/chapter_model.dart';
import '../models/providers/chapters_provider.dart';
import 'expandable_widget.dart';

class LearningDescription extends StatefulWidget {
  const LearningDescription({Key? key, required this.chapter})
      : super(key: key);

  final ChapterModel chapter;

  @override
  State<LearningDescription> createState() => _LearningDescriptionState();
}

class _LearningDescriptionState extends State<LearningDescription> {
  @override
  Widget build(BuildContext context) {
    return ExpandableWidget(
      expandedStateKey: 'description',
      icon: const Icon(Icons.description_outlined),
      header: const Text(
        'chapters.description',
        style: TextStyle(fontSize: 20),
      ).tr(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            ChaptersProvider.getChapterTranslatableDescription(
                widget.chapter.chapterName),
          ).dtr(context),
        ),
      ),
    );
  }
}
