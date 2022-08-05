import 'dart:convert';

import 'package:arabella/assets/models/chapter_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chapters_provider.dart';

class CoveredMaterialProvider with ChangeNotifier {
  ChaptersProvider? _chaptersProvider;
  Map<String, List<String>> _finishedLessons = {};
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

  Map<String, List<String>> get finishedMaterial => _finishedLessons;

  set finishedMaterial(Map<String, List<String>> value) {
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

  Map<String, List<String>> getInitializedMaterialStatus() {
    Map<String, List<String>> initializedMaterialStatus = {};

    for (ChapterModel chapterModel in _chaptersProvider!.chapters) {
      initializedMaterialStatus[chapterModel.chapterName] = [];
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

  void fromJson(Map<String, dynamic> parsedJson) {
    _finishedLessons = Map<String, dynamic>.from(parsedJson['finishedLessons'])
        .map((String a, dynamic b) => MapEntry(a, List<String>.from(b)));
    _finishedQuizzes = Map<String, double>.from(parsedJson['finishedQuizzes']);
  }

  Map<String, dynamic> toJson() => {
        'finishedLessons': _finishedLessons,
        'finishedQuizzes': _finishedQuizzes,
      };
}