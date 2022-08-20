import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/chapter_model.dart';
import '../models/providers/chapters_provider.dart';
import 'expandable_widget.dart';

class LearningOutcomes extends StatefulWidget {
  const LearningOutcomes({Key? key, required this.chapter}) : super(key: key);

  final ChapterModel chapter;

  @override
  State<LearningOutcomes> createState() => _LearningOutcomesState();
}

class _LearningOutcomesState extends State<LearningOutcomes> {
  late Future<List<String>> learningOutcomes;

  @override
  void initState() {
    super.initState();
    learningOutcomes = ChaptersProvider.getChapterTranslatableLearningOutcomes(
        widget.chapter.chapterName);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<String> chapterTranslatableLearningOutcomes =
              snapshot.data as List<String>;
          return ExpandableWidget(
            expandedStateKey: 'learning_outcomes',
            icon: const Icon(Icons.school_outlined),
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
                      visualDensity:
                          const VisualDensity(horizontal: 0, vertical: -2),
                      horizontalTitleGap: -10,
                      leading: const Icon(Icons.circle, size: 15),
                      title: Text(
                        chapterTranslatableLearningOutcomes[i],
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
      future: learningOutcomes,
    );
  }
}
