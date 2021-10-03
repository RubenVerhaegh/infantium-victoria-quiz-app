// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:myapp/SharedData.dart';
import 'package:material_dialogs/material_dialogs.dart';

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
      backgroundColor: Color.fromRGBO(0, 0, 0, 1),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: UpdateText(),
          )
        ],
      ),
    );
  }
}

class UpdateText extends StatefulWidget {
  UpdateTextState createState() => UpdateTextState();
}

class UpdateTextState extends State {
  Question _currentQuestion = new Question("", true, "");
  bool showingQuestion = true;
  bool showingAnimation = false;
  bool correctlyAnswered;
  // bool answered    = false;
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
      Stack(children: <Widget> [
        if (sd.nrWrongAnswers < 10) Image.asset(
          "images/stills1/" + (sd.nrWrongAnswers+1).toString() + ".png",
          fit: BoxFit.fitHeight,
        ),
        Image.asset(
          "images/stills1/" + sd.nrWrongAnswers.toString() + ".png",
          fit: BoxFit.fitHeight,
        ),
        if (showingAnimation) Image.asset(
          "animations/screen1/" + (sd.nrWrongAnswers + 1).toString() + ".gif",
          fit: BoxFit.fitHeight,
        ),
        Column(children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(30, 0.05*sd.deviceHeight(context), 30, 10),
            height: (0.4 - 2*0.05)*sd.deviceHeight(context),
            width: 350,
            decoration: BoxDecoration(
              color: sd.offWhite,
              border: Border.all(
                color: sd.offWhite,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  height: 130,
                  width: 340,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.07),
                    border: Border.all(
                      color: Colors.black.withOpacity(0),
                    ),
                    borderRadius: BorderRadius.circular(7.5)
                  ),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: showingQuestion ? Text(
                        _currentQuestion.question,
                        style: TextStyle(fontSize: 20.0)
                      ) : Text(
                        (correctlyAnswered ? "That is indeed " : "That is actually ") +
                            _currentQuestion.correctAnswer.toString() + ". " +
                            _currentQuestion.explanation,
                        style: TextStyle(fontSize: 20.0)
                      ),
                    )
                  ),
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showingQuestion) Container(
                    margin: EdgeInsets.fromLTRB(10,0,10,0),
                    child: ElevatedButton(
                      child: Text('True', style: TextStyle(fontSize: 20.0),),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.green)
                      ),
                      onPressed: () {
                        answerQuestion(true);
                      },
                    ),
                  ),
                  if (showingQuestion) Container(
                    margin: EdgeInsets.fromLTRB(10,0,10,0),
                    child: ElevatedButton(
                      child: Text('False', style: TextStyle(fontSize: 20.0),),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red)
                      ),
                      onPressed: () {
                        answerQuestion(false);
                      },
                    ),
                  ),
                  if(!showingQuestion) Container(
                    margin: EdgeInsets.all(0),
                    child: ElevatedButton(
                      child: Text('Continue', style: TextStyle(fontSize: 20.0),),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Color.fromRGBO(50, 50, 50, 1))
                      ),
                      onPressed: () {
                        continueAfterAnswer();
                      },
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ]),
        Positioned(
          bottom: 20,
          right: 20,
          child: Stack(children: <Widget>[
            MaterialButton(
              child:  Icon(
                Icons.checkroom,
                color: Colors.white,
              ),
              height: 56,
              minWidth: 56,
              shape: CircleBorder(),
              color: Colors.green,
              elevation: 2.0,
              onPressed: () {
                Future.delayed(const Duration(milliseconds: 500), () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SecondRoute()));
                });
              },
            ),
            if (sd.nrGoodAnswers > 0) notificationDot(sd.nrGoodAnswers),
          ]),
        ),
      ]);
  }

  void nextQuestion() async {
    var newQuestion = await sd.randomQuestion();
    setState(() {
      showingQuestion = true;
      showingAnimation = false;
      _currentQuestion = newQuestion;
    });
  }

  void continueAfterAnswer() async {
    if (correctlyAnswered) {
      // First do stuff here
      sd.goodAnswer();
      nextQuestion();
    } else {
      setState(() {
        showingAnimation = true;
      });

      int delayTime = 1000 * sd.animationDuration[sd.nrWrongAnswers];
      print('DELAY TIME = ' + delayTime.toString());
      Future.delayed(Duration(milliseconds: delayTime), () {
        sd.wrongAnswer();
        if (sd.nrWrongAnswers == 1) {
          Dialogs.materialDialog(
              context: context,
              title: "Actions have consequences",
              msg: "As you can see, our decisions impact the world directly. "
                  "Make too many wrong decisions and the earth will be destroyed.",
              actions: [
                IconsButton(
                  text: "Continue",
                  iconData: Icons.navigate_next,
                  color: Colors.blue,
                  textStyle: TextStyle(color: Colors.white),
                  iconColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                    nextQuestion();
                  },
                )
              ]
          );
        } else {
          setState(() {
            nextQuestion();
          });
        }
      });

    }
  }

  void answerQuestion(bool givenAnswer) {
    bool correct = (givenAnswer == _currentQuestion.correctAnswer);

    setState(() {
      correctlyAnswered = correct;
      showingQuestion = false;
    });
  }

  Container notificationDot(int count) {
    return Container(
      width: 20,
      height: 20,
      decoration: new BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(child: Text(
        count.toString(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      )),
    );
  }
}

/* ============
 * SECOND ROUTE
 * ============ */
class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      backgroundColor: Colors.brown,
      body: StatefulSecondRoute(),
    );
  }
}

class StatefulSecondRoute extends StatefulWidget {
  //const StatefulSecondRoute({Key? key}) : super(key: key);

  @override
  State<StatefulSecondRoute> createState() => _StatefulSecondRouteState();
}

class _StatefulSecondRouteState extends State<StatefulSecondRoute> {
  List placed = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            for (int i = 1; i <= 5; i++)
              if (!placed.contains(i) && SharedData.instance.nrGoodAnswers >= i)
                tokenDraggable(i)
              else
                Container(
                  width: 40, height: 40,
                )
          ]
        ),
        SizedBox(height: 50),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              for (int i = 1; i <= 5; i++) new Stack(
                children: [
                  tokenDragTarget(i, false),
                  if (placed[i-1] > 0) tokenDraggable(placed[i-1]),
                  if (placed[i-1] > 0) tokenDragTarget(i, true),
                ],
              )
            ]
        )
      ]
    );
  }

  DragTarget<int> tokenDragTarget(int i, bool invisible) {
    return new DragTarget<int>(
      builder: (
          BuildContext context,
          List<dynamic> accepted,
          List<dynamic> rejected,
          ) {
        return tokenTargetContainer(invisible);
      },
      onAccept: (int data) {
        print("dragged " + data.toString() + " to " + i.toString());
        setState(() {
          for (int j = 0; j < placed.length; j++) {
            if (placed[j] == data) {
              placed[j] = 0;
            }
          }
          placed[i-1] = data;
        });
        print(placed);
      },
    );
  }
}

Draggable<int> tokenDraggable(int i) {
  return new Draggable<int>(
    data: i,
    feedback: tokenContainer(i),
    child: tokenContainer(i),
    childWhenDragging: new Container(
      height: 40,
      width:  40,
    ),
  );
}

Container tokenContainer(int i) {
  return new Container(
    height: 40,
    width:  40,
    decoration: new BoxDecoration(
      image: new DecorationImage(
          image: new AssetImage("assets/images/tokens/example-token-" + i.toString() + ".png"),
          fit: BoxFit.scaleDown
      ),
    ),
  );
}

Container tokenTargetContainer(bool invisible) {
  if (invisible) {
    return new Container(
      height: 40,
      width:  40
    );
  } else {
    return new Container(
      height: 40,
      width:  40,
      decoration: new BoxDecoration(
        image: new DecorationImage(
            image: new AssetImage("assets/images/tokens/example-token-target.png"),
            fit: BoxFit.scaleDown
        ),
      ),
    );
  }
}