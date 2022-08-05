import 'package:arabella/assets/models/chapter_model.dart';
import 'package:arabella/assets/models/providers/answered_questions_provider.dart';
import 'package:arabella/assets/models/providers/chapters_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuestionState extends StatefulWidget {
  const QuestionState(
      {Key? key, required this.chapterName, required this.questionIndex})
      : super(key: key);

  final String chapterName;
  final int questionIndex;

  @override
  State<QuestionState> createState() => _QuestionStateState();
}

class _QuestionStateState extends State<QuestionState> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AnsweredQuestionsProvider>(
      builder: (context, answeredQuestions, child) {
        switch (getQuestionState(answeredQuestions)) {
          case 1:
            return const Icon(Icons.save_as);
          case 2:
            return const Icon(Icons.check);
          case 3:
            return const Icon(Icons.close);
          default:
            return const Icon(Icons.access_time);
        }
      },
    );
  }

  int getQuestionState(AnsweredQuestionsProvider answeredQuestions) {
    ChapterModel chapter = context
        .read<ChaptersProvider>()
        .chapters
        .firstWhere((chapter) => chapter.chapterName == widget.chapterName);

    return answeredQuestions.getQuestionStatus(
        widget.chapterName, chapter.questions[widget.questionIndex].question);
  }
}