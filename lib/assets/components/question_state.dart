import 'package:arabella/assets/models/providers/answered_questions_provider.dart';
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
        switch (answeredQuestions.getQuestionStatus(
            widget.chapterName, widget.questionIndex)) {
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
}
