// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:myapp/SharedData.dart';

import 'Question.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Title',
      home: MainLayout(),
    );
  }
}

class MainLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      body: new Stack(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage("assets/images/Milky-Way-Galaxy.jpg"),
                  fit: BoxFit.fill
              ),
            ),
          ),
          new Center(
            child: UpdateText(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SecondRoute()));
        },
        label: Text("To second page"),
        icon:  Icon(Icons.navigation),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: Text("So far, this has got to be my favorite page.")
      ),
    );
  }
}

class UpdateText extends StatefulWidget {
  UpdateTextState createState() => UpdateTextState();
}

class UpdateTextState extends State {
  Question _currentQuestion = new Question("", true, "");
  bool answered    = false;
  bool prevCorrect = true;
  SharedData sd = SharedData.instance;

  @override
  void initState() {
    _setup();
    super.initState();
  }

  _setup() async {
    Question question = await sd.randomQuestion();
    setState(() {
      _currentQuestion = question;
      print("QUESTION:" + question.question);
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      Column(children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(30, 50, 30, 10),
          height: 180,
          width: 350,
          color: Colors.orange,
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: !answered ? Text(
                  _currentQuestion.question,
                  style: TextStyle(fontSize: 20.0)
              ) : Text(
                  (prevCorrect ? "That is correct. " : "That is wrong. ") +
                  _currentQuestion.explanation,
                  style: TextStyle(fontSize: 20.0)
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                !answered ? Container(
                  margin: EdgeInsets.all(0),
                  child: TextButton(
                    child: Text('Yes', style: TextStyle(fontSize: 20.0),),
                    onPressed: () {
                      answerQuestion(true);
                    },
                  ),
                ) : Container(),
                !answered ? Container(
                  margin: EdgeInsets.all(0),
                  child: TextButton(
                    child: Text('No', style: TextStyle(fontSize: 20.0),),
                    onPressed: () {
                      answerQuestion(false);
                    },
                  ),
                ) : Container(),
                answered ? Container(
                  margin: EdgeInsets.all(0),
                  child: TextButton(
                    child: Text('Next', style: TextStyle(fontSize: 20.0),),
                    onPressed: () {
                      nextQuestion();
                    },
                  ),
                ) : Container(),
              ],
            ),
          ]),
        ),
        Stack(children: [
          new Container(
            height: 300,
            width:  300,
            decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage("assets/images/earth_start.png"),
                  fit: BoxFit.scaleDown
              ),
            ),
          ),
          for (var i = 0; i < min(sd.nrWrongAnswers, sd.nrDisasters); i++) new Container(
            height: 300,
            width:  300,
            decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage("assets/images/disaster" +
                      sd.disasterIndices[i].toString() +
                      ".png"),
                  fit: BoxFit.scaleDown
              ),
            ),
          ),
        ]),
        Text(sd.nrGoodAnswers.toString()  + " good answers",
        style: TextStyle(color: Colors.white)),
        Text(sd.nrWrongAnswers.toString() + " wrong answers",
            style: TextStyle(color: Colors.white))
      ]);
  }

  void nextQuestion() async {
    var newQuestion = await sd.randomQuestion();
    setState(() {
      answered = false;
      _currentQuestion = newQuestion;
    });
  }

  void answerQuestion(bool givenAnswer) {
    bool correct = givenAnswer == _currentQuestion.correctAnswer;
    correct ? sd.goodAnswer() : sd.wrongAnswer();

    setState(() {
      prevCorrect = correct;
      answered = true;
    });
  }
}