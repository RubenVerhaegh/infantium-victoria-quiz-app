import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:myapp/Question.dart';

class SharedData {
  static final SharedData instance = SharedData._internal();
  List<Question> _questions;
  int _nrGoodAnswers  = 0;
  int _nrWrongAnswers = 0;
  int _nrDisasters = 10;
  int _nrQuestionsAsked = 0;
  List<int> animationDuration = [11, 10, 10, 11, 9, 11, 11, 7, 10, 10];

  double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

  double frameWidth(BuildContext context) => frameHeight(context) * 9.0 / 16.0;
  double frameHeight(BuildContext context) => deviceHeight(context);

  Color _offWhite = Color.fromRGBO(249, 243, 222, 1);

  factory SharedData() {
    return instance;
  }

  SharedData._internal();

  Future<Question> randomQuestion() async {
    if (_questions == null) {
      await readQuestions();
      _questions.shuffle(new Random());
    }

    if (_nrQuestionsAsked == _questions.length) {
      resetQuestions();
    }

    return _questions[_nrQuestionsAsked++].ask();
  }

  void resetQuestions() {
    _nrQuestionsAsked = 0;
    _questions.forEach((question) {
      question.reset();
    });
    _questions.shuffle(new Random());
  }

  Future<void> readQuestions() async {
    print("Reading questions...");
    _questions = [];

    try {
      final String string = await rootBundle.loadString("lib/questions.json");
      var questionsList = jsonDecode(string);
      assert(questionsList is List);

      for (int i = 0; i < questionsList.length; i ++) {
        var q = questionsList[i];
        String question = q["question"];
        bool   correct  = q["answer"] == "true" ? true : false;
        String explanation = q["explanation"];
        _questions.add(new Question(question, correct, explanation));
      }
    } catch (err) {
      print('Caught error: $err');
    }
  }

  void goodAnswer() {
    _nrGoodAnswers++;
  }

  void wrongAnswer() {
    _nrWrongAnswers++;
  }

  void restartGame() {
    _nrGoodAnswers = 0;
    _nrWrongAnswers = 0;
  }

  get nrWrongAnswers => _nrWrongAnswers;
  get nrGoodAnswers => _nrGoodAnswers;
  get nrDisasters => _nrDisasters;
  get nrUnaskedQuestions => _nrQuestionsAsked;
  get offWhite => _offWhite;
}