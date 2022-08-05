import 'dart:convert';

import 'package:arabella/assets/models/chapter_model.dart';
import 'package:arabella/assets/models/providers/covered_material_provider.dart';
import 'package:arabella/assets/models/question_model.dart';
import 'package:arabella/assets/models/quiz_metadata.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chapters_provider.dart';

class AnsweredQuestionsProvider with ChangeNotifier {
  ChaptersProvider? _chaptersProvider;
  CoveredMaterialProvider? _coveredMaterialProvider;
  Map<String, Map<String, List<String>>> _answers = {};
  Map<String, bool> _isSubmitted = {};

  AnsweredQuestionsProvider() {
    loadPersistentSate();
  }

  Future<void> loadPersistentSate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('answeredQuestions')) {
      fromJson(json.decode(prefs.getString('answeredQuestions')!));
    }
    notifyListeners();
  }

  Future<void> savePersistentSate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String state = json.encode(toJson());
    prefs.setString('answeredQuestions', state);
    notifyListeners();
  }

  void update(ChaptersProvider chaptersProvider,
      CoveredMaterialProvider coveredMaterialProvider) {
    _chaptersProvider = chaptersProvider;
    _coveredMaterialProvider = coveredMaterialProvider;

    if (_answers.isEmpty || _isSubmitted.isEmpty) {
      initializeAnswers();
    }
  }

  Map<String, Map<String, List<String>>> get answers => _answers;

  set answers(Map<String, Map<String, List<String>>> value) {
    _answers = value;
    savePersistentSate();
  }

  Map<String, bool> get isSubmitted => _isSubmitted;

  set isSubmitted(Map<String, bool> value) {
    _isSubmitted = value;
    savePersistentSate();
  }

  void initializeAnswers() {
    _answers = getInitializedQuestionsOptions();
    _isSubmitted = getInitializedSubmissionStatus();
  }

  Map<String, Map<String, List<String>>> getInitializedQuestionsOptions() {
    Map<String, Map<String, List<String>>> initializedQuestionsOptions = {};

    for (ChapterModel chapterModel in _chaptersProvider!.chapters) {
      initializedQuestionsOptions[chapterModel.chapterName] = {};
      for (QuestionModel questionModel in chapterModel.questions) {
        initializedQuestionsOptions[chapterModel.chapterName]![
            questionModel.question] = [];
      }
    }

    return initializedQuestionsOptions;
  }

  Map<String, bool> getInitializedSubmissionStatus() {
    Map<String, bool> initializedSubmissionStatus = {};

    for (ChapterModel chapterModel in _chaptersProvider!.chapters) {
      initializedSubmissionStatus[chapterModel.chapterName] = false;
    }

    return initializedSubmissionStatus;
  }

  List<String> getQuestionAnswer(String chapterName, String questionName) {
    return _answers[chapterName]![questionName]!;
  }

  void answerQuestionRadio(
      String chapterName, String questionName, String optionName) {
    _isSubmitted[chapterName] = false;
    _answers[chapterName]![questionName] = [optionName];

    savePersistentSate();
  }

  void answerQuestionCheckBox(String chapterName, String questionName,
      String optionName, bool isChecked) {
    _isSubmitted[chapterName] = false;
    if (isChecked) {
      _answers[chapterName]![questionName]!.add(optionName);
    } else {
      _answers[chapterName]![questionName]!.remove(optionName);
    }

    savePersistentSate();
  }

  bool shouldCheckBoxBeChecked(
      String chapterName, String questionName, String optionName) {
    return _answers[chapterName]![questionName]!.contains(optionName);
  }

  bool containsMultipleAnswers(String chapterName, String questionName) {
    ChapterModel chapter = _chaptersProvider!.chapters
        .firstWhere((chapter) => chapter.chapterName == chapterName);

    QuestionModel question = chapter.questions
        .firstWhere((question) => question.question == questionName);

    return question.correctOptionsIndex
            .where((correct) => correct == 1)
            .length !=
        1;
  }

  int getQuestionStatus(String chapterName, String questionName) {
    List<String> answer = _answers[chapterName]![questionName]!;

    if (_isSubmitted[chapterName]!) {
      if (isAnswerCorrect(chapterName, questionName)) {
        return 2;
      } else {
        return 3;
      }
    } else {
      if (answer.isNotEmpty) {
        return 1;
      } else {
        return 0;
      }
    }
  }

  bool areAnswersEligibleForSubmission(String chapterName) {
    for (List<String> answer in _answers[chapterName]!.values) {
      if (answer.isEmpty) {
        return false;
      }
    }
    return true;
  }

  QuizMetadata getQuizResults(String chapterName) {
    _isSubmitted[chapterName] = true;

    int obtainedMark = 0;

    List<QuestionModel> questions = _chaptersProvider!.chapters
        .firstWhere((chapter) => chapter.chapterName == chapterName)
        .questions;

    for (MapEntry<String, List<String>> questionWithAnswer
        in _answers[chapterName]!.entries) {
      QuestionModel currentQuestion = questions.firstWhere(
          (question) => question.question == questionWithAnswer.key);

      List<String> correctOptions = [];
      for (int i = 0; i < currentQuestion.options.length; i++) {
        if (currentQuestion.correctOptionsIndex[i] == 1) {
          correctOptions.add(currentQuestion.options[i]);
        }
      }

      if (setEquals(questionWithAnswer.value.toSet(), correctOptions.toSet())) {
        obtainedMark++;
      }
    }

    QuizMetadata quizMetadata = QuizMetadata(obtainedMark, questions.length);

    _coveredMaterialProvider!.setQuizMark(
        chapterName, quizMetadata.obtainedMark / quizMetadata.totalMarks);

    savePersistentSate();
    return quizMetadata;
  }

  bool isAnswerCorrect(String chapterName, String questionName) {
    QuestionModel question = _chaptersProvider!.chapters
        .firstWhere((chapter) => chapter.chapterName == chapterName)
        .questions
        .firstWhere((question) => question.question == questionName);

    List<String> correctOptions = [];
    for (int i = 0; i < question.options.length; i++) {
      if (question.correctOptionsIndex[i] == 1) {
        correctOptions.add(question.options[i]);
      }
    }

    return setEquals(
        _answers[chapterName]![questionName]!.toSet(), correctOptions.toSet());
  }

  void fromJson(Map<String, dynamic> parsedJson) {
    _answers = Map<String, dynamic>.from(parsedJson['answers']).map(
        (String a, dynamic b) => MapEntry(
            a,
            Map<String, dynamic>.from(b).map(
                (String c, dynamic d) => MapEntry(c, List<String>.from(d)))));
    _isSubmitted = Map<String, bool>.from(parsedJson['isSubmitted']);
  }

  Map<String, dynamic> toJson() => {
        'answers': _answers,
        'isSubmitted': _isSubmitted,
      };
}
