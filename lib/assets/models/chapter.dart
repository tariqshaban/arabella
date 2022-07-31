import 'package:arabella/assets/models/question.dart';

class Chapter {
  String chapterName;
  List<String> lessons = [];
  List<Question> questions = [];

  Chapter(this.chapterName);
}
