import 'package:arabella/assets/models/chapter_model.dart';
import 'package:flutter/cupertino.dart';

import 'chapters_provider.dart';

class CoveredMaterialProvider with ChangeNotifier {
  ChaptersProvider? _chaptersProvider;
  Map<String, Map<String, bool>> _finishedLessons = {};
  Map<String, double> _finishedQuizzes = {};

  void update(ChaptersProvider chaptersProvider){
    _chaptersProvider = chaptersProvider;

    if(_finishedLessons.isEmpty || _finishedQuizzes.isEmpty) {
      initializeMaterial();
    }
  }

  Map<String, Map<String, bool>> get finishedMaterial => _finishedLessons;

  set finishedMaterial(Map<String, Map<String, bool>> value) {
    _finishedLessons = value;
    notifyListeners();
  }

  Map<String, double> get finishedQuizzes => _finishedQuizzes;

  set finishedQuizzes(Map<String, double> value) {
    _finishedQuizzes = value;
    notifyListeners();
  }

  void initializeMaterial() {
    _finishedLessons = getInitializedMaterialStatus();
    _finishedQuizzes = getInitializedQuizzesStatus();
  }

  Map<String, Map<String, bool>> getInitializedMaterialStatus() {
    Map<String, Map<String, bool>> initializedMaterialStatus = {};

    for (ChapterModel chapterModel in _chaptersProvider!.chapters) {
      initializedMaterialStatus[chapterModel.chapterName] = {};
      for (String lessons in chapterModel.lessons) {
        initializedMaterialStatus[chapterModel.chapterName]![lessons] = false;
      }
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
    _finishedLessons[chapterName]![lessonName] = true;

    notifyListeners();
  }

  void setQuizMark(String chapterName, double mark) {
    if(_finishedQuizzes[chapterName]! < mark) {
      _finishedQuizzes[chapterName] = mark;
    }

    notifyListeners();
  }

  bool isLessonFinished(String chapterName, String lessonName) {
    return _finishedLessons[chapterName]![lessonName]!;
  }

  double getQuizMark(String chapterName) {
    return _finishedQuizzes[chapterName]!;
  }
}
