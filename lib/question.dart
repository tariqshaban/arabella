import 'package:arabella/assets/models/providers/answered_questions_provider.dart';
import 'package:arabella/assets/models/providers/chapters_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import 'assets/components/extended_floating_action_button.dart';
import 'assets/models/providers/scroll_direction_provider.dart';
import 'assets/models/question_model.dart';

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
                      child: MarkdownBody(data: snapshot.data as String),
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
                      child:
                          NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (notification) {
                          notification.disallowIndicator();
                          return true;
                        },
                        child: Consumer<AnsweredQuestionsProvider>(
                          builder: (context, answeredQuestions, child) {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: widget.currentQuestion.options.length,
                              itemBuilder: (context, i) {
                                return (answeredQuestions
                                        .containsMultipleAnswers(
                                            widget.chapterName,
                                            widget.questions.indexOf(
                                                widget.currentQuestion)))
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
                                            data: (snapshot.data
                                                as List<String>)[i]),
                                      )
                                    : RadioListTile(
                                        contentPadding: EdgeInsets.zero,
                                        value: i,
                                        groupValue: getRadioState(context, i),
                                        onChanged: (value) {
                                          radioEventHandler(
                                              context, i, value as int);
                                        },
                                        title: MarkdownBody(
                                            data: (snapshot.data
                                                as List<String>)[i]),
                                      );
                              },
                            );
                          },
                        ),
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
                Navigator.popAndPushNamed(context, '/question', arguments: {
                  'chapterName': widget.chapterName,
                  'questions': widget.questions,
                  'currentQuestion': widget.questions[getNextQuestionIndex()],
                });
              },
            )
          : null,
    );
  }

  bool getCheckboxState(BuildContext context, int i) {
    AnsweredQuestionsProvider answeredQuestions =
        context.read<AnsweredQuestionsProvider>();

    return answeredQuestions.shouldCheckBoxBeChecked(widget.chapterName,
        widget.questions.indexOf(widget.currentQuestion), i);
  }

  void checkboxEventHandler(BuildContext context, int i, bool value) {
    AnsweredQuestionsProvider answeredQuestions =
        context.read<AnsweredQuestionsProvider>();

    answeredQuestions.answerQuestionCheckBox(widget.chapterName,
        widget.questions.indexOf(widget.currentQuestion), i, value);
  }

  int getRadioState(BuildContext context, int i) {
    AnsweredQuestionsProvider answeredQuestions =
        context.read<AnsweredQuestionsProvider>();

    return answeredQuestions
        .getQuestionAnswer(widget.chapterName,
            widget.questions.indexOf(widget.currentQuestion))
        .indexOf(1);
  }

  void radioEventHandler(BuildContext context, int i, int value) {
    AnsweredQuestionsProvider answeredQuestions =
        context.read<AnsweredQuestionsProvider>();

    answeredQuestions.answerQuestionRadio(widget.chapterName,
        widget.questions.indexOf(widget.currentQuestion), value);
  }

  int getQuestionIndex() {
    return widget.questions.indexOf(widget.currentQuestion);
  }

  int getNextQuestionIndex() {
    int nextIndex = getQuestionIndex() + 1;

    return (nextIndex == widget.questions.length) ? -1 : nextIndex;
  }
}
