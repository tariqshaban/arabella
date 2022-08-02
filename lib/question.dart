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
                  return Card(
                    elevation: 5,
                    shadowColor: Theme.of(context).colorScheme.primary,
                    child: InkWell(
                      onTap: () {},
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
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.currentQuestion.options.length,
                          itemBuilder: (context, i) {
                            return Card(
                              elevation: 5,
                              shadowColor:
                                  Theme.of(context).colorScheme.primary,
                              child: InkWell(
                                onTap: () {},
                                child: MarkdownBody(
                                    data: (snapshot.data as List<String>)[i]),
                              ),
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
              icon: const Icon(Icons.upload_file),
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

  int getNextQuestionIndex() {
    int nextIndex = widget.questions.indexOf(widget.currentQuestion) + 1;

    return (nextIndex == widget.questions.length) ? -1 : nextIndex;
  }
}
