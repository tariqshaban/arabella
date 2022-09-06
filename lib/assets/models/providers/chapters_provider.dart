import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../enums/assets_state.dart';
import '../chapter_model.dart';
import '../question_model.dart';
import 'assets_provider.dart';

class ChaptersProvider with ChangeNotifier {
  List<ChapterModel> _chapters = [];
  bool didMount = false;

  List<ChapterModel> get chapters => _chapters;

  set chapters(List<ChapterModel> value) {
    _chapters = value;
    notifyListeners();
  }

  void update(AssetsProvider assetsProvider) {
    if (assetsProvider.assetsState == AssetsState.noUpdateRequired ||
        assetsProvider.assetsState == AssetsState.finishedUpdating) {
      if (!didMount) {
        mountChapters();
        didMount = true;
      }

      notifyListeners();
    }
  }

  static String getChapterTranslatableName(String chapter) {
    return 'chapters.${chapter.substring(chapter.indexOf('-') + 1)}.name';
  }

  static String getChapterTranslatableDescription(String chapter) {
    return 'chapters.${chapter.substring(chapter.indexOf('-') + 1)}.description';
  }

  static Future<List<String>> getChapterTranslatableLearningOutcomes(
      String chapter) async {
    List<String> translatableLearningOutcomes = [];

    dynamic data = await json.decode(await File(
            '${(await getApplicationDocumentsDirectory()).path}/assets/translations/en.json')
        .readAsString());

    dynamic outcomes = data['chapters']
        [chapter.substring(chapter.indexOf('-') + 1)]['outcomes'];

    outcomes.keys.forEach((key) {
      translatableLearningOutcomes.add(
          'chapters.${chapter.substring(chapter.indexOf('-') + 1)}.outcomes.$key');
    });

    return translatableLearningOutcomes;
  }

  static Future<String> getLessonContents(
      BuildContext context, String chapter, String lesson) async {
    String path =
        '${(await getApplicationDocumentsDirectory()).path}/assets/chapters/${context.locale.toString()}/$chapter/lessons/$lesson';

    return await File(path).readAsString();
  }

  static Future<String> getQuizQuestionContents(
      BuildContext context, String chapter, String quiz) async {
    String path =
        '${(await getApplicationDocumentsDirectory()).path}/assets/chapters/${context.locale.toString()}/$chapter/quiz/$quiz';

    return await File(path).readAsString();
  }

  static Future<List<String>> getQuizOptionsContents(
      BuildContext context, String chapter, List<String> options) async {
    List<String> contents = [];

    for (String option in options) {
      String path =
          '${(await getApplicationDocumentsDirectory()).path}/assets/chapters/${context.locale.toString()}/$chapter/quiz/$option';

      contents.add(await File(path).readAsString());
    }

    return contents;
  }

  static String getLessonTranslatableName(String chapter, String lesson) {
    return 'chapters.${chapter.substring(chapter.indexOf('-') + 1)}.lessons.${lesson.substring(lesson.indexOf('-') + 1, lesson.lastIndexOf('.'))}.name';
  }

  static String getImageFromLesson(
      AssetsProvider assetsProvider, String chapter, String lesson) {
    return '${assetsProvider.applicationDocumentsDirectory}/assets/images/chapters/$chapter/cover_images/${lesson.substring(0, lesson.indexOf("."))}.jpg';
  }

  static bool isMultipleChoiceQuestion(QuestionModel question) {
    return question.correctOptionsIndex
            .where((correct) => correct == 1)
            .length ==
        1;
  }

  Future<void> mountChapters() async {
    String root =
        '${(await getApplicationDocumentsDirectory()).path}/assets/chapters/en/';

    final components = Directory(root)
        .listSync(recursive: true)
        .whereType<File>()
        .map((e) => e.path)
        .toList();

    for (String component in components) {
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
