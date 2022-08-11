import 'dart:convert';

import 'package:arabella/assets/models/chapter_model.dart';
import 'package:arabella/assets/models/quiz_metadata.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chapters_provider.dart';

class CoveredMaterialProvider with ChangeNotifier {
  ChaptersProvider? _chaptersProvider;
  Map<String, Set<String>> _finishedLessons = {};
  Map<String, double> _finishedQuizzes = {};

  CoveredMaterialProvider() {
    loadPersistentSate();
  }

  Future<void> loadPersistentSate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('coveredMaterial')) {
      fromJson(json.decode(prefs.getString('coveredMaterial')!));
    }
    notifyListeners();
  }

  Future<void> savePersistentSate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String state = json.encode(toJson());
    prefs.setString('coveredMaterial', state);
    notifyListeners();
  }

  void update(ChaptersProvider chaptersProvider) {
    _chaptersProvider = chaptersProvider;

    if (_finishedLessons.isEmpty || _finishedQuizzes.isEmpty) {
      initializeMaterial();
    }
  }

  Map<String, Set<String>> get finishedMaterial => _finishedLessons;

  set finishedMaterial(Map<String, Set<String>> value) {
    _finishedLessons = value;
    savePersistentSate();
  }

  Map<String, double> get finishedQuizzes => _finishedQuizzes;

  set finishedQuizzes(Map<String, double> value) {
    _finishedQuizzes = value;
    savePersistentSate();
  }

  void initializeMaterial() {
    _finishedLessons = getInitializedMaterialStatus();
    _finishedQuizzes = getInitializedQuizzesStatus();
  }

  Map<String, Set<String>> getInitializedMaterialStatus() {
    Map<String, Set<String>> initializedMaterialStatus = {};

    for (ChapterModel chapterModel in _chaptersProvider!.chapters) {
      initializedMaterialStatus[chapterModel.chapterName] = {};
    }

    return initializedMaterialStatus;
  }

  Map<String, double> getInitializedQuizzesStatus() {
    Map<String, double> initializedQuizzesStatus = {};

    for (ChapterModel chapterModel in _chaptersProvider!.chapters) {
      initializedQuizzesStatus[chapterModel.chapterName] = -1;
    }

    return initializedQuizzesStatus;
  }

  void setLessonAsFinished(String chapterName, String lessonName) {
    _finishedLessons[chapterName]!.add(lessonName);

    savePersistentSate();
  }

  void setQuizMark(String chapterName, double mark) {
    if (_finishedQuizzes[chapterName]! < mark) {
      _finishedQuizzes[chapterName] = mark;
    }

    savePersistentSate();
  }

  bool isLessonFinished(String chapterName, String lessonName) {
    return _finishedLessons[chapterName]!.contains(lessonName);
  }

  double getQuizMark(String chapterName) {
    return _finishedQuizzes[chapterName]!;
  }

  String serializeFinishedLessons() {
    return json.encode(_finishedLessons);
  }

  Map<String, dynamic> deserializeFinishedLessons(
      String serializedFinishedLessons) {
    return json.decode(serializedFinishedLessons);
  }

  String serializeFinishedQuizzes() {
    return json.encode(_finishedQuizzes);
  }

  Map<String, dynamic> deserializeFinishedQuizzes(
      String serializedFinishedQuizzes) {
    return json.decode(serializedFinishedQuizzes);
  }

  bool _isEligibleForBadge(String chapterName) {
    List<String> lessons = _chaptersProvider!.chapters
        .firstWhere((chapter) => chapter.chapterName == chapterName)
        .lessons;

    for (String lesson in lessons) {
      if (!_finishedLessons[chapterName]!.contains(lesson)) {
        return false;
      }
    }

    if (!_finishedQuizzes.containsKey(chapterName) ||
        _finishedQuizzes[chapterName]! < QuizMetadata.passingMark) {
      return false;
    }

    return true;
  }

  Map<String, bool> getEligibleBadges() {
    Map<String, bool> eligibleBadges = {};
    for (ChapterModel chapter in _chaptersProvider!.chapters) {
      eligibleBadges[chapter.chapterName] =
          _isEligibleForBadge(chapter.chapterName);
    }
    return eligibleBadges;
  }

  bool isEligibleForCompletionBadge() {
    return !getEligibleBadges().values.contains(false);
  }

  double getChapterProgress(String chapterName) {
    int numberOfLessons = _chaptersProvider!.chapters
        .firstWhere((chapter) => chapter.chapterName == chapterName)
        .lessons
        .length;
    int coveredLessons = _finishedLessons[chapterName]!.length;
    int coveredQuiz = (_finishedQuizzes.containsKey(chapterName) &&
            _finishedQuizzes[chapterName]! >= QuizMetadata.passingMark)
        ? 1
        : 0;

    return (coveredLessons + coveredQuiz) / (numberOfLessons + 1);
  }

  void fromJson(Map<String, dynamic> parsedJson) {
    _finishedLessons = Map<String, dynamic>.from(parsedJson['finishedLessons'])
        .map((String a, dynamic b) => MapEntry(a, Set<String>.from(b)));
    _finishedQuizzes = Map<String, double>.from(parsedJson['finishedQuizzes']);
  }

  Map<String, dynamic> toJson() => {
        'finishedLessons': _finishedLessons
            .map((String a, Set<String> b) => MapEntry(a, b.toList())),
        'finishedQuizzes': _finishedQuizzes,
      };
}
