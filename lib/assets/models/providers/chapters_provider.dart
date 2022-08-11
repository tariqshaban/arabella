import 'dart:convert';

import 'package:arabella/assets/models/question_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../chapter_model.dart';

class ChaptersProvider with ChangeNotifier {
  List<ChapterModel> _chapters = [];

  ChaptersProvider() {
    mountChapters();

    notifyListeners();
  }

  List<ChapterModel> get chapters => _chapters;

  set chapters(List<ChapterModel> value) {
    _chapters = value;
    notifyListeners();
  }

  static String getChapterTranslatableName(String chapter) {
    return 'chapters.${chapter.substring(chapter.indexOf('-') + 1)}.name';
  }

  static Future<String> getLessonContents(
      BuildContext context, String chapter, String lesson) async {
    String path =
        'assets/chapters/${context.locale.toString()}/$chapter/lessons/$lesson';
    return await rootBundle.loadString(path);
  }

  static Future<String> getQuizQuestionContents(
      BuildContext context, String chapter, String quiz) async {
    String path =
        'assets/chapters/${context.locale.toString()}/$chapter/quiz/$quiz';

    return await rootBundle.loadString(path);
  }

  static Future<List<String>> getQuizOptionsContents(
      BuildContext context, String chapter, List<String> options) async {
    List<String> contents = [];

    for (String option in options) {
      String path =
          'assets/chapters/${context.locale.toString()}/$chapter/quiz/$option';
      contents.add(await rootBundle.loadString(path));
    }

    return contents;
  }

  static String getLessonTranslatableName(String chapter, String lesson) {
    return 'chapters.${chapter.substring(chapter.indexOf('-') + 1)}.lessons.${lesson.substring(lesson.indexOf('-') + 1, lesson.lastIndexOf('.'))}.name';
  }

  static String getImageFromLesson(String chapter, String lesson) {
    return 'assets/images/chapters/$chapter/cover_images/${lesson.substring(0, lesson.indexOf("."))}.jpg';
  }

  static bool isMultipleChoiceQuestion(QuestionModel question) {
    return question.correctOptionsIndex
            .where((correct) => correct == 1)
            .length ==
        1;
  }

  Future<void> mountChapters() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final components = json
        .decode(manifestJson)
        .keys
        .where((String key) =>
            key.startsWith('assets/chapters/') && key.contains('/en/'))
        .toList();

    for (String component in components) {
      String root = 'assets/chapters/en/';

      component = component.replaceFirst(root, '');
      String chapterComponent = component.substring(0, component.indexOf('/'));

      if (!_chapters
          .any((chapter) => chapter.chapterName == chapterComponent)) {
        _chapters.add(ChapterModel(chapterComponent));
      }

      if (component.contains('/quiz/')) {
        String questionComponent =
            component.substring(component.lastIndexOf('/') + 1);

        if (!questionComponent.contains('-')) {
          continue;
        }

        String questionName =
            '${questionComponent.substring(0, questionComponent.indexOf('-'))}.md';

        if (!_chapters.last.questions
            .any((question) => question.question == questionName)) {
          _chapters.last.questions.add(QuestionModel(questionName));
        }

        if (questionComponent.contains('option')) {
          _chapters.last.questions.last.options.add(questionComponent);
          if (questionComponent.contains('correct')) {
            _chapters.last.questions.last.correctOptionsIndex.add(1);
          } else {
            _chapters.last.questions.last.correctOptionsIndex.add(0);
          }
        }
      } else {
        String lessonName = component.substring(component.lastIndexOf('/') + 1);
        _chapters.last.lessons.add(lessonName);
      }
    }

    for (ChapterModel chapter in _chapters) {
      for (QuestionModel question in chapter.questions) {
        List<String> shuffledOptions = List.from(question.options);
        List<int> shuffledCorrectOptionsIndex = [];
        shuffledOptions.shuffle();

        for (String option in shuffledOptions) {
          int displacedIndex = question.options.indexOf(option);
          shuffledCorrectOptionsIndex
              .add(question.correctOptionsIndex[displacedIndex]);
        }

        question.options = shuffledOptions;
        question.correctOptionsIndex = shuffledCorrectOptionsIndex;
      }
    }
  }
}
