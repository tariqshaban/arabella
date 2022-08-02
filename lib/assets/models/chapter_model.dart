import 'package:arabella/assets/models/question_model.dart';

class ChapterModel {
  String chapterName;
  List<String> lessons = [];
  List<QuestionModel> questions = [];

  ChapterModel(this.chapterName);
}
