import 'package:arabella/assets/models/providers/answered_questions_provider.dart';
import 'package:arabella/assets/models/providers/chapters_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'assets/components/extended_floating_action_button.dart';
import 'assets/components/snack_bar.dart';
import 'assets/models/providers/confetti_provider.dart';
import 'assets/models/providers/scroll_direction_provider.dart';
import 'assets/models/question_model.dart';
import 'assets/models/quiz_metadata.dart';

class Question extends StatefulWidget {
  const Question(
      {Key? key,
      required this.chapterName,
      required this.questions,
      required this.currentQuestion})
      : super(key: key);

  final String chapterName;
  final List<QuestionModel> questions;
  final QuestionModel currentQuestion;

  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${ChaptersProvider.getChapterTranslatableName(widget.chapterName).tr()} - ${'quiz.quiz'.tr()}'),
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
        child: Column(
          children: [
            FutureBuilder(
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: MarkdownBody(
                        fitContent: false,
                        data: snapshot.data as String,
                        onTapLink: (text, url, title) async {
                          await launchUrl(
                            Uri.parse(url!),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              future: ChaptersProvider.getQuizQuestionContents(
                  context, widget.chapterName, widget.currentQuestion.question),
            ),
            FutureBuilder(
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Expanded(
                    child: NotificationListener<UserScrollNotification>(
                      onNotification: (notification) {
                        if (notification.direction == ScrollDirection.idle) {
                          return true;
                        }
                        context.read<ScrollDirectionProvider>().direction =
                            notification.direction;
                        return true;
                      },
                      child: Consumer<AnsweredQuestionsProvider>(
                        builder: (context, answeredQuestions, child) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: widget.currentQuestion.options.length,
                            itemBuilder: (context, i) {
                              return (answeredQuestions.containsMultipleAnswers(
                                      widget.chapterName,
                                      widget.currentQuestion.question))
                                  ? CheckboxListTile(
                                      contentPadding: EdgeInsets.zero,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value: getCheckboxState(context, i),
                                      onChanged: (value) {
                                        checkboxEventHandler(
                                            context, i, value!);
                                      },
                                      title: MarkdownBody(
                                        fitContent: false,
                                        data:
                                            (snapshot.data as List<String>)[i],
                                        onTapLink: (text, url, title) async {
                                          await launchUrl(
                                            Uri.parse(url!),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                      ),
                                    )
                                  : RadioListTile(
                                      contentPadding: EdgeInsets.zero,
                                      value: i,
                                      groupValue: getRadioState(context),
                                      onChanged: (value) {
                                        radioEventHandler(
                                            context, i, value as int);
                                      },
                                      title: MarkdownBody(
                                        fitContent: false,
                                        data:
                                            (snapshot.data as List<String>)[i],
                                        onTapLink: (text, url, title) async {
                                          await launchUrl(
                                            Uri.parse(url!),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                      ),
                                    );
                            },
                          );
                        },
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              future: ChaptersProvider.getQuizOptionsContents(
                  context, widget.chapterName, widget.currentQuestion.options),
            ),
          ],
        ),
      ),
      floatingActionButton: (getNextQuestionIndex() != -1)
          ? ExtendedFloatingActionButton(
              text: const Text('question.next').tr(),
              icon: const Icon(Icons.navigate_next),
              iconFirst: false,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/question',
                    arguments: {
                      'chapterName': widget.chapterName,
                      'questions': widget.questions,
                      'currentQuestion':
                          widget.questions[getNextQuestionIndex()],
                    });
              },
            )
          : Consumer<AnsweredQuestionsProvider>(
              builder: (context, answeredQuestions, child) {
                if (!answeredQuestions.isSubmitted[widget.chapterName]!) {
                  return ExtendedFloatingActionButton(
                    text: const Text('quiz.submit').tr(),
                    icon: const Icon(Icons.upload_file),
                    onPressed: () {
                      if (context
                          .read<AnsweredQuestionsProvider>()
                          .areAnswersEligibleForSubmission(
                              widget.chapterName)) {
                        QuizMetadata results = context
                            .read<AnsweredQuestionsProvider>()
                            .getQuizResults(widget.chapterName);

                        if (results.isPassed) {
                          SnackBars.showTextSnackBar(
                              context, 'quiz.passed'.tr());
                          context.read<ConfettiProvider>().play();
                        } else {
                          SnackBars.showTextSnackBar(
                              context, 'quiz.failed'.tr());
                        }
                        Navigator.of(context).pop();
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

  bool getCheckboxState(BuildContext context, int i) {
    AnsweredQuestionsProvider answeredQuestions =
        context.read<AnsweredQuestionsProvider>();

    String optionName = widget.currentQuestion.options[i];

    return answeredQuestions.shouldCheckBoxBeChecked(
        widget.chapterName, widget.currentQuestion.question, optionName);
  }

  void checkboxEventHandler(BuildContext context, int i, bool value) {
    AnsweredQuestionsProvider answeredQuestions =
        context.read<AnsweredQuestionsProvider>();

    String optionName = widget.currentQuestion.options[i];

    answeredQuestions.answerQuestionCheckBox(
        widget.chapterName, widget.currentQuestion.question, optionName, value);
  }

  int getRadioState(BuildContext context) {
    AnsweredQuestionsProvider answeredQuestions =
        context.read<AnsweredQuestionsProvider>();

    List<String> selectedOption = answeredQuestions.getQuestionAnswer(
        widget.chapterName, widget.currentQuestion.question);

    if (selectedOption.isEmpty) {
      return -1;
    }

    List<String> options = widget.currentQuestion.options;

    return options.indexOf(selectedOption.first);
  }

  void radioEventHandler(BuildContext context, int i, int value) {
    AnsweredQuestionsProvider answeredQuestions =
        context.read<AnsweredQuestionsProvider>();

    answeredQuestions.answerQuestionRadio(widget.chapterName,
        widget.currentQuestion.question, widget.currentQuestion.options[i]);
  }

  int getQuestionIndex() {
    return widget.questions.indexOf(widget.currentQuestion);
  }

  int getNextQuestionIndex() {
    int nextIndex = getQuestionIndex() + 1;

    return (nextIndex == widget.questions.length) ? -1 : nextIndex;
  }
}
