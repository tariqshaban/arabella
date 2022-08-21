import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'assets/components/extended_floating_action_button.dart';
import 'assets/components/question_state.dart';
import 'assets/components/snack_bar.dart';
import 'assets/models/chapter_model.dart';
import 'assets/models/providers/answered_questions_provider.dart';
import 'assets/models/providers/chapters_provider.dart';
import 'assets/models/providers/confetti_provider.dart';
import 'assets/models/providers/covered_material_provider.dart';
import 'assets/models/providers/scroll_direction_provider.dart';
import 'assets/models/question_model.dart';
import 'assets/models/quiz_metadata.dart';

class Quiz extends StatefulWidget {
  const Quiz({Key? key, required this.chapterName, required this.questions})
      : super(key: key);

  final String chapterName;
  final List<QuestionModel> questions;

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${ChaptersProvider.getChapterTranslatableName(widget.chapterName).tr()} - ${'quiz.quiz'.tr()}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(15, 5, 15, 15),
            child: Consumer<CoveredMaterialProvider>(
              builder: (context, coveredMaterial, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Consumer<AnsweredQuestionsProvider>(
                      builder: (context, answeredQuestions, child) {
                        return (answeredQuestions
                                .isQuizSubmitted(widget.chapterName))
                            ? Text(
                                '${'quiz.your_grade'.tr()}:  ${(coveredMaterial.getQuizMark(widget.chapterName) * 100).round()}%',
                                style: const TextStyle(fontSize: 16),
                              )
                            : Text(
                                '${'quiz.passing_grade'.tr()}:  ${(coveredMaterial.getPassingGrade() * 100).round()}%',
                                style: const TextStyle(fontSize: 16),
                              );
                      },
                    ),
                    (coveredMaterial.didPassQuiz(widget.chapterName))
                        ? Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.green,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 15,
                            ),
                          )
                        : const SizedBox(),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.idle) {
                  return true;
                }
                context.read<ScrollDirectionProvider>().direction =
                    notification.direction;
                return true;
              },
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: constraints.maxWidth > 900
                            ? constraints.maxWidth > 1200
                                ? 4
                                : 3
                            : constraints.maxWidth > 600
                                ? 2
                                : 1,
                        mainAxisExtent: 70,
                        mainAxisSpacing: 0,
                        crossAxisSpacing: 15,
                      ),
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: widget.questions.length,
                      itemBuilder: (context, i) {
                        return Consumer<AnsweredQuestionsProvider>(
                          builder: (context, answeredQuestions, child) {
                            return Center(
                              child: Card(
                                margin: const EdgeInsetsDirectional.fromSTEB(
                                    0, 5, 0, 5),
                                elevation: 5,
                                shadowColor:
                                    Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(
                                    color: getBorderColor(answeredQuestions, i),
                                    width: 2,
                                  ),
                                ),
                                child: ListTile(
                                  leading: QuestionState(
                                    chapterName: widget.chapterName,
                                    questionIndex: i,
                                  ),
                                  title: Text(
                                      '${'quiz.question_number'.tr()} ${i + 1}'),
                                  trailing: (ChaptersProvider
                                          .isMultipleChoiceQuestion(
                                              widget.questions[i]))
                                      ? const Icon(Icons.radio_button_checked)
                                      : const Icon(Icons.check_box),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  onTap: () => Navigator.pushNamed(
                                      context, '/question',
                                      arguments: {
                                        'chapterName': widget.chapterName,
                                        'questions': widget.questions,
                                        'currentQuestion': widget.questions[i],
                                      }),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<AnsweredQuestionsProvider>(
        builder: (context, answeredQuestions, child) {
          if (!answeredQuestions.isQuizSubmitted(widget.chapterName)) {
            return ExtendedFloatingActionButton(
              text: 'quiz.submit'.tr(),
              icon: const Icon(Icons.upload_file),
              onPressed: () {
                if (context
                    .read<AnsweredQuestionsProvider>()
                    .areAnswersEligibleForSubmission(widget.chapterName)) {
                  QuizMetadata results = context
                      .read<AnsweredQuestionsProvider>()
                      .getQuizResults(widget.chapterName);

                  if (results.isPassed) {
                    SnackBars.showTextSnackBar(context, 'quiz.passed'.tr());
                    context.read<ConfettiProvider>().play();
                  } else {
                    SnackBars.showTextSnackBar(context, 'quiz.failed'.tr());
                  }
                } else {
                  SnackBars.showTextSnackBar(
                      context, 'quiz.not_all_answered'.tr());
                }
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Color getBorderColor(
      AnsweredQuestionsProvider answeredQuestions, int questionIndex) {
    switch (getQuestionState(answeredQuestions, questionIndex)) {
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }

  int getQuestionState(
      AnsweredQuestionsProvider answeredQuestions, int questionIndex) {
    ChapterModel chapter = context
        .read<ChaptersProvider>()
        .chapters
        .firstWhere((chapter) => chapter.chapterName == widget.chapterName);

    return answeredQuestions.getQuestionStatus(
        widget.chapterName, chapter.questions[questionIndex].question);
  }
}
