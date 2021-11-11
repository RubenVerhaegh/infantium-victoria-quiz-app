import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:myapp/Question.dart';

// This singleton class serves as an interface for different parts of the app to
// share data which persists during the lifetime of the app. (No data is stored
// between sessions).
class SharedData {
  static final SharedData instance = SharedData._internal();

  // Password, in case the content of the app should be blocked by a password.
  // Probably no longer necessary when releasing as app, but nice to keep in
  // case of another limited access web release.
  // Given the specific use case scenario of the password, password security
  // was not relevant and a hard coded password like was sufficient.
  String _password = "RFSAntwerp";

  List<Question> _questions;
  int _nrGoodAnswers  = 0;
  int _nrWrongAnswers = 0;
  int _nrDisasters = 10;
  int _nrTokens = 10;
  int _nrQuestionsAsked = 0;

  // How many seconds each animation of earth takes
  List<int> animationDuration = [11, 10, 10, 11, 9, 11, 11, 7, 10, 10];

  // Which token is placed at each of the targets (initially none)
  List tokenPlacement = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

  // The size of the frame in which all content is displayed
  double frameWidth(BuildContext context) => frameHeight(context) * 9.0 / 16.0;
  double frameHeight(BuildContext context) => deviceHeight(context);
  double smallFrameWidth(BuildContext context) => frameHeight(context) * 540 / 1080;

  double fontSize(BuildContext context) => 0.03 * frameHeight(context);

  // Whether this is the first time this session that the first screen is visited
  bool firstTime = true;
  // Whether the second screen has been visited earlier this session
  bool hasVisitedSecondScreen = false;
  // Whether the game was just completed
  bool completed = false;

  // Colors
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

  // Prepare the questions for another round of the game.
  void resetQuestions() {
    _nrQuestionsAsked = 0;
    _questions.forEach((question) {
      question.reset();
    });
    _questions.shuffle(new Random());
  }

  Future<void> readQuestions() async {
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
  get nrTokens => _nrTokens;
  get nrUnaskedQuestions => _nrQuestionsAsked;

  get offWhite => _offWhite;
  Color get disabledTextColor => _disabledTextColor;
  Color get enabledTextColor => _enabledTextColor;
  Color get disabledButtonColor => _disabledButtonColor;
  Color get enabledButtonColor => _enabledButtonColor;
  String get password => _password;
}