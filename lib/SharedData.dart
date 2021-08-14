import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:myapp/Question.dart';

class SharedData {
  static final SharedData instance = SharedData._internal();
  List<Question> _questions;
  int _nrGoodAnswers  = 0;
  int _nrWrongAnswers = 0;
  int _nrDisasters = 10;
  List<int> _disasterIndices;

  factory SharedData() {
    return instance;
  }

  SharedData._internal();

  Future<Question> randomQuestion() async {
    if (_questions == null) {
      await readQuestions();
      randomizeDisasterOrder();
    }

    var random = new Random();
    return _questions[random.nextInt(_questions.length)];
  }

  Future<void> readQuestions() async {
    print("Reading questions...");
    _questions = [];

    // Question question = new Question("What is the correct answer?", true);
    // _questions.add(question);

    try {
      final String string = await rootBundle.loadString("lib/questions.json");
      // String content = '['
      //     '{'
      //       '"question": "This is the first test question (yes).",'
      //       '"answers": ["Yes", "No"],'
      //       '"correct": "Yes",'
      //       '"explanation": "Due to explanation 1."'
      //     '},'
      //     '{'
      //       '"question": "This is the second test question (no).",'
      //       '"answers": ["Yes", "No"],'
      //       '"correct": "No",'
      //       '"explanation": "Due to explanation 2."'
      //     '},'
      //     '{'
      //       '"question": "This is the third test question (yes).",'
      //       '"answers": ["Yes", "No"],'
      //       '"correct": "Yes",'
      //       '"explanation": "Due to explanation 3."'
      //     '},'
      //     '{'
      //       '"question": "This is the fourth test question (no).",'
      //       '"answers": ["Yes", "No"],'
      //       '"correct": "No",'
      //       '"explanation": "Due to explanation 4."'
      //     '},'
      //     '{'
      //       '"question": "This is the fifth test question (yes).",'
      //       '"answers": ["Yes", "No"],'
      //       '"correct": "Yes",'
      //       '"explanation": "Due to explanation 5."'
      //     '},'
      //     '{'
      //       '"question": "This is the sixth test question (no).",'
      //       '"answers": ["Yes", "No"],'
      //       '"correct": "No",'
      //       '"explanation": "Due to explanation 6."'
      //     '},'
      //     '{'
      //       '"question": "This is the seventh test question (yes).",'
      //       '"answers": ["Yes", "No"],'
      //       '"correct": "Yes",'
      //       '"explanation": "Due to explanation 7."'
      //     '},'
      //     '{'
      //       '"question": "This is the eighth test question (no).",'
      //       '"answers": ["Yes", "No"],'
      //       '"correct": "No",'
      //       '"explanation": "Due to explanation 8."'
      //     '},'
      //     '{'
      //       '"question": "This is the ninth test question (yes).",'
      //       '"answers": ["Yes", "No"],'
      //       '"correct": "Yes",'
      //       '"explanation": "Due to explanation 9."'
      //     '},'
      //     '{'
      //       '"question": "This is the tenth test question (no).",'
      //       '"answers": ["Yes", "No"],'
      //       '"correct": "No",'
      //       '"explanation": "Due to explanation 10."'
      //     '}]';
      var questionsList = jsonDecode(string);
      assert(questionsList is List);

      for (int i = 0; i < questionsList.length; i ++) {
        var q = questionsList[i];
        String question = q["question"];
        bool   correct  = q["correct"] == "Yes" ? true : false;
        String explanation = q["explanation"];
        _questions.add(new Question(question, correct, explanation));
      }
    } catch (err) {
      print('Caught error: $err');
    }
  }

  List<int> initializeList() {
    var list = [_nrDisasters];
    for (int i=0; i < _nrDisasters; i++) {
      list[i] = i+1;
    }
    print(list);
    return list;
  }

  void randomizeDisasterOrder() {
    _disasterIndices = List.filled(_nrDisasters, 1);
    for (int i = 0; i < _nrDisasters; i++) {
      _disasterIndices[i] = i+1;
    }
    _disasterIndices.shuffle();
  }

  void goodAnswer() {
    _nrGoodAnswers++;
  }

  void wrongAnswer() {
    _nrWrongAnswers++;
  }

  get nrWrongAnswers => _nrWrongAnswers;
  get nrGoodAnswers => _nrGoodAnswers;
  get nrDisasters => _nrDisasters;
  get disasterIndices => _disasterIndices;
}