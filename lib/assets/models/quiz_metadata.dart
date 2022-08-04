class QuizMetadata {
  static const double passingMark = 0.6;
  int obtainedMark;
  int totalMarks;
  bool isPassed = false;

  QuizMetadata(this.obtainedMark, this.totalMarks) {
    isPassed = (obtainedMark / totalMarks >= passingMark);
  }
}
