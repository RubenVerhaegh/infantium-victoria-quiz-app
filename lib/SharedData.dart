import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:myapp/Question.dart';

class SharedData {
  static final SharedData instance = SharedData._internal();
  String _password = "RFSAntwerp";
  List<Question> _questions;
  int _nrGoodAnswers  = 0;
  int _nrWrongAnswers = 0;
  int _nrDisasters = 10;
  int _nrQuestionsAsked = 0;
  List<int> animationDuration = [11, 10, 10, 11, 9, 11, 11, 7, 10, 10];
  List tokenPlacement = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

  double frameWidth(BuildContext context) => frameHeight(context) * 9.0 / 16.0;
  double frameHeight(BuildContext context) => deviceHeight(context);
  double smallFrameWidth(BuildContext context) => frameHeight(context) * 540 / 1080;

  double fontSize(BuildContext context) => 0.03 * frameHeight(context);

  bool firstTime = true;
  bool hasVisitedSecondScreen = false;
  bool completed = false;

  Color _offWhite = Color.fromRGBO(249, 243, 222, 1);
  Color _enabledButtonColor = Color.fromRGBO(80, 80, 80, 1);
  Color _disabledButtonColor = Color.fromRGBO(110, 110, 110, 1);
  Color _enabledTextColor = Color.fromRGBO(255, 255, 255, 1);
  Color _disabledTextColor = Color.fromRGBO(180, 180, 180, 1);

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
    tokenPlacement = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  }

  get nrWrongAnswers => _nrWrongAnswers;
  get nrGoodAnswers => _nrGoodAnswers;
  get nrDisasters => _nrDisasters;
  get nrUnaskedQuestions => _nrQuestionsAsked;

  get offWhite => _offWhite;
  Color get disabledTextColor => _disabledTextColor;
  Color get enabledTextColor => _enabledTextColor;
  Color get disabledButtonColor => _disabledButtonColor;
  Color get enabledButtonColor => _enabledButtonColor;
  String get password => _password;
}