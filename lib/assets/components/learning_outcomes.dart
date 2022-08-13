import 'package:arabella/assets/components/expandable_widget.dart';
import 'package:arabella/assets/models/chapter_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/providers/chapters_provider.dart';

class LearningOutcomes extends StatefulWidget {
  const LearningOutcomes({Key? key, required this.chapter}) : super(key: key);

  final ChapterModel chapter;

  @override
  State<LearningOutcomes> createState() => _LearningOutcomesState();
}

class _LearningOutcomesState extends State<LearningOutcomes> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<String> chapterTranslatableLearningOutcomes =
              snapshot.data as List<String>;
          return ExpandableWidget(
            expandedStateKey: 'learning_outcomes',
            header: const Text(
              'chapters.learning_outcomes',
              style: TextStyle(fontSize: 20),
            ).tr(),
            body: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: chapterTranslatableLearningOutcomes.length,
              itemBuilder: (context, i) {
                return Builder(
                  builder: (BuildContext context) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      horizontalTitleGap: 0,
                      leading: const Icon(Icons.circle, size: 20),
                      title: Text(
                        chapterTranslatableLearningOutcomes[i],
                        style: const TextStyle(fontSize: 16),
                      ).tr(),
                    );
                  },
                );
              },
            ),
          );
        }
        return const SizedBox();
      },
      future: ChaptersProvider.getChapterTranslatableLearningOutcomes(
          widget.chapter.chapterName),
    );
  }
}
