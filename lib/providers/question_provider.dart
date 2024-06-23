import 'dart:math';

import 'package:ccapp/models/question_model.dart';
import 'package:flutter/material.dart';

class QuestionProvider with ChangeNotifier {
  final List<Question> _questions = [
        Question(
        question: "Syntak dengan console.log(\"Makan Nasi\") adalah  ?",
        trueAnswer: "Skrip Jawa",
        falseAnswer1: "Ular Piton",
        falseAnswer2: "Flutter",
        falseAnswer3: "Karat"),
    Question(
        question: "Vitamin apa yang bikin stres ?",
        trueAnswer: "C++",
        falseAnswer1: "A",
        falseAnswer2: "B+",
        falseAnswer3: "B2"),
    Question(
        question: "Krim apa yang mengerikan ?",
        trueAnswer: "Krim Jong Un",
        falseAnswer1: "Es Krim",
        falseAnswer2: "Cat Krim",
        falseAnswer3: "Krimer"),
    Question(
        question: "Kota apa yang memproduksi banyak kamera ?",
        trueAnswer: "KulonGopro",
        falseAnswer1: "Sleman",
        falseAnswer2: "Condong Catur",
        falseAnswer3: "Godean"),
    Question(
        question: "Ikan apa yang cerewet ?",
        trueAnswer: "Ikan Bawel",
        falseAnswer1: "Ikan Makan Nasi",
        falseAnswer2: "Ikan Lele",
        falseAnswer3: "Ikan Koi"),
    Question(
        question: "Ikan apa yang suka bersih-bersih ?",
        trueAnswer: "Cleaning ShareFish",
        falseAnswer1: "Ikan Sapu-sapu",
        falseAnswer2: "Ikan Lele",
        falseAnswer3: "Ikan Makan Nasi"),
    Question(
        question: "Hewan apa yang tidak apa suaranya ?",
        trueAnswer: "Se-mute",
        falseAnswer1: "Lalat",
        falseAnswer2: "Ikan Makan Nasi",
        falseAnswer3: "Capung"),
    Question(
        question: "Sayur apa yang sudah punah ?",
        trueAnswer: "Dino Sayurus",
        falseAnswer1: "Bayam Purba",
        falseAnswer2: "Kangkung Cino",
        falseAnswer3: "Mie Bantul"),

  ];

  List<Question> get questions => _questions;

  List<Map<String, dynamic>> get questionsWithRandomAnswers {
    return _questions.map((question) {
      List<String> randomAnswers = [
        question.trueAnswer,
        question.falseAnswer1,
        question.falseAnswer2,
        question.falseAnswer3,
      ];
      randomAnswers.shuffle(Random());
      return {
        'question': question.question,
        'answers': randomAnswers,
      };
    }).toList();
  }

  void addQuestion(Question question) {
    _questions.add(question);
    notifyListeners();
  }

  void updateQuestion(int index, Question question) {
    _questions[index] = question;
    notifyListeners();
  }

  void deleteQuestion(int index) {
    _questions.removeAt(index);
    notifyListeners();
  }
}
