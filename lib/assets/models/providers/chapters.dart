import 'dart:convert';

import 'package:arabella/assets/models/question.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../chapter.dart';

class Chapters with ChangeNotifier {
  List<Chapter> _chapters = [];

  Chapters() {
    mountChapters();

    notifyListeners();
  }

  List<Chapter> get chapters => _chapters;

  set chapters(List<Chapter> value) {
    _chapters = value;
    notifyListeners();
  }

  static String getChapterTranslatableName(String chapter) {
    return 'chapters.${chapter.substring(chapter.indexOf('-') + 1)}.name';
  }

  static String getLessonTranslatableName(String chapter, String lesson) {
    return 'chapters.${chapter.substring(chapter.indexOf('-') + 1)}.lessons.${lesson.substring(lesson.indexOf('-') + 1, lesson.lastIndexOf('.'))}.name';
  }

  static String getImageFromLesson(String chapter, String lesson) {
    return 'assets/images/chapters/$chapter/${lesson.substring(0, lesson.indexOf("."))}.jpg';
  }

  Future<void> mountChapters() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final components = json
        .decode(manifestJson)
        .keys
        .where((String key) => key.startsWith('assets/chapters/'))
        .toList();

    for (String component in components) {
      String root = 'assets/chapters/';

      component = component.replaceFirst(root, '');
      String chapterComponent = component.substring(0, component.indexOf('/'));

      if (!_chapters
          .any((chapter) => chapter.chapterName == chapterComponent)) {
        _chapters.add(Chapter(chapterComponent));
      }

      if (component.contains('/quiz/')) {
        String questionComponent =
            component.substring(component.lastIndexOf('/') + 1);

        if (!questionComponent.contains('-')) {
          continue;
        }

        String questionName =
            questionComponent.substring(0, questionComponent.indexOf('-'));

        if (!_chapters.last.questions
            .any((question) => question.question == questionName)) {
          _chapters.last.questions.add(Question(questionName));
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

    for (Chapter chapter in _chapters) {
      for (Question question in chapter.questions) {
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
