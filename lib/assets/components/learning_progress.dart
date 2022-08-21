import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';

import '../models/chapter_model.dart';
import '../models/providers/covered_material_provider.dart';

class LearningProgress extends StatefulWidget {
  const LearningProgress({Key? key, required this.chapter}) : super(key: key);

  final ChapterModel chapter;

  @override
  State<LearningProgress> createState() => _LearningProgressState();
}

class _LearningProgressState extends State<LearningProgress> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CoveredMaterialProvider>(
      builder: (context, coveredMaterial, child) {
        return Card(
          margin: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
          elevation: 5,
          shadowColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {},
            child: Stack(
              children: [
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  top: 0,
                  end: 0,
                  child: Hero(
                    tag: 'attempt_exam ${widget.chapter.chapterName}',
                    child: Consumer<CoveredMaterialProvider>(
                      builder: (context, coveredMaterial, child) {
                        return Material(
                          color: Colors.transparent,
                          child: IconButton(
                            tooltip: 'chapters.attempt_quiz'.tr(),
                            iconSize: 20,
                            icon: const Icon(
                              Icons.note_alt,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/quiz',
                                  arguments: {
                                    'chapterName': widget.chapter.chapterName,
                                    'questions': widget.chapter.questions
                                  });
                            },
                            color: (coveredMaterial
                                    .didPassQuiz(widget.chapter.chapterName))
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary,
                            splashRadius: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        margin: const EdgeInsetsDirectional.only(end: 30),
                        child: LiquidCircularProgressIndicator(
                          value: coveredMaterial
                              .getChapterProgress(widget.chapter.chapterName),
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).colorScheme.primary),
                          borderColor: Theme.of(context).colorScheme.primary,
                          borderWidth: 2,
                          // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                          center: Text(
                            '${(coveredMaterial.getChapterProgress(widget.chapter.chapterName) * 100).round()}%',
                            style: const TextStyle(fontSize: 25),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getLessonsWidget(
                              widget.chapter.chapterName, coveredMaterial),
                          getMarkWidget(
                              widget.chapter.chapterName, coveredMaterial),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget getLessonsWidget(
      String chapterName, CoveredMaterialProvider coveredMaterial) {
    bool didComplete = coveredMaterial
            .getNumberOfFinishedLessons(widget.chapter.chapterName) ==
        coveredMaterial.getNumberOfLessons(widget.chapter.chapterName);

    if (didComplete) {
      return Text(
        '${'chapters.lessons_finished'.tr()}: ${coveredMaterial.getNumberOfFinishedLessons(widget.chapter.chapterName)}/${coveredMaterial.getNumberOfLessons(widget.chapter.chapterName)}',
        style: const TextStyle(fontSize: 16, color: Colors.green),
      );
    } else {
      return Text(
        '${'chapters.lessons_finished'.tr()}: ${coveredMaterial.getNumberOfFinishedLessons(widget.chapter.chapterName)}/${coveredMaterial.getNumberOfLessons(widget.chapter.chapterName)}',
        style: const TextStyle(fontSize: 16),
      );
    }
  }

  Widget getMarkWidget(
      String chapterName, CoveredMaterialProvider coveredMaterial) {
    double mark = coveredMaterial.getQuizMark(chapterName);
    bool didPassQuiz = coveredMaterial.didPassQuiz(widget.chapter.chapterName);
    String pretext = 'chapters.grade'.tr();

    if (mark == -1) {
      return Text(
        '$pretext: ??',
        style: const TextStyle(fontSize: 16),
      );
    } else if (didPassQuiz) {
      return Text(
        '$pretext: ${(mark * 100).round()}%',
        style: const TextStyle(fontSize: 16, color: Colors.green),
      );
    } else {
      return Text(
        '$pretext: ${(mark * 100).round()}%',
        style: const TextStyle(fontSize: 16, color: Colors.red),
      );
    }
  }
}
