import 'dart:math';

class Question {
  final String question;
  final String trueAnswer;
  final String falseAnswer1;
  final String falseAnswer2;
  final String falseAnswer3;
  List<String>? shuffledAnswers;

  Question({
    required this.question,
    required this.trueAnswer,
    required this.falseAnswer1,
    required this.falseAnswer2,
    required this.falseAnswer3,
  }) {
    shuffleAnswers();
  }

  void shuffleAnswers() {
    shuffledAnswers = [
      trueAnswer,
      falseAnswer1,
      falseAnswer2,
      falseAnswer3,
    ];
    shuffledAnswers!.shuffle(Random());
  }
}

