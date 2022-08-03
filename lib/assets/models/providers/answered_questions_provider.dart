import 'package:arabella/assets/models/chapter_model.dart';
import 'package:arabella/assets/models/question_model.dart';
import 'package:flutter/cupertino.dart';

import 'chapters_provider.dart';

class AnsweredQuestionsProvider with ChangeNotifier {
  final ChaptersProvider? _chaptersProvider;
  List<List<List<int>>> _answers = [];

  AnsweredQuestionsProvider(this._chaptersProvider) {
    if (_chaptersProvider != null) {
      initializeAnswers();
    }
    notifyListeners();
  }

  List<List<List<int>>> get answers => _answers;

  set answers(List<List<List<int>>> value) {
    _answers = value;
    notifyListeners();
  }

  void initializeAnswers() {
    _answers = _chaptersProvider!.getUninitializedQuestionsOptions();
  }

  List<int> getQuestionAnswer(String chapterName, int questionIndex) {
    ChapterModel chapter = _chaptersProvider!.chapters
        .firstWhere((chapter) => chapter.chapterName == chapterName);
    int chapterIndex = _chaptersProvider!.chapters.indexOf(chapter);

    return _answers[chapterIndex][questionIndex];
  }

  void answerQuestionRadio(String chapterName, int questionIndex, int index) {
    ChapterModel chapter = _chaptersProvider!.chapters
        .firstWhere((chapter) => chapter.chapterName == chapterName);
    int chapterIndex = _chaptersProvider!.chapters.indexOf(chapter);

    _answers[chapterIndex][questionIndex] =
        List.filled(_answers[chapterIndex][questionIndex].length, 0);
    _answers[chapterIndex][questionIndex][index] = 1;

    notifyListeners();
  }

  void answerQuestionCheckBox(
      String chapterName, int questionIndex, int index, bool isChecked) {
    ChapterModel chapter = _chaptersProvider!.chapters
        .firstWhere((chapter) => chapter.chapterName == chapterName);
    int chapterIndex = _chaptersProvider!.chapters.indexOf(chapter);
    int value = (isChecked) ? 1 : 0;

    _answers[chapterIndex][questionIndex][index] = value;

    notifyListeners();
  }

  bool shouldCheckBoxBeChecked(
      String chapterName, int questionIndex, int index) {
    ChapterModel chapter = _chaptersProvider!.chapters
        .firstWhere((chapter) => chapter.chapterName == chapterName);
    int chapterIndex = _chaptersProvider!.chapters.indexOf(chapter);

    return _answers[chapterIndex][questionIndex][index] == 1;
  }

  bool containsMultipleAnswers(String chapterName, int questionIndex) {
    ChapterModel chapter = _chaptersProvider!.chapters
        .firstWhere((chapter) => chapter.chapterName == chapterName);

    QuestionModel question = chapter.questions[questionIndex];

    return question.correctOptionsIndex
            .where((correct) => correct == 1)
            .length !=
        1;
  }

  int getQuestionStatus(String chapterName, int questionIndex) {
    ChapterModel chapter = _chaptersProvider!.chapters
        .firstWhere((chapter) => chapter.chapterName == chapterName);
    int chapterIndex = _chaptersProvider!.chapters.indexOf(chapter);

    List<int> answer = answers[chapterIndex][questionIndex];

    if(answer.contains(1)){
      return 1;
    }

    return 0;
  }
}
