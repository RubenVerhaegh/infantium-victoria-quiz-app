// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:myapp/SharedData.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:video_player/video_player.dart';

import 'Question.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Let's save the earth! - Infantium Victoria",
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
  @override
  _UpdateTextState createState() => _UpdateTextState();
}

class _UpdateTextState extends State {
  SharedData sd = SharedData.instance;
  Question _currentQuestion = new Question("", true, "");
  bool showingQuestion = true;
  bool showingAnimation = false;
  bool correctlyAnswered;
  int tokenPhase = 0;

  VideoPlayerController _videoController;
  Future<void> _initializedVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void dispose() {
    super.dispose();
    _videoController.dispose();
  }

  _setup() async {
    Question question = await sd.randomQuestion();
    print(sd.frameHeight(context));
    setState(() {
      _currentQuestion = question;
      _videoController = VideoPlayerController.asset(
        "animations/screen1/1.mp4",
      );
      _initializedVideoPlayerFuture = _videoController.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          height: sd.frameHeight(context),
          width: sd.frameWidth(context),
          child: firstScreenContent()
      ),
    );
  }

  Stack firstScreenContent() {
    return Stack(children: <Widget> [
      Align(
        alignment: Alignment.topCenter,
        child: earth(),
      ),
      Align(
        alignment: Alignment.topCenter,
        child: questionCard(),
      ),
      tokenAnimation(),
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
              if (!showingAnimation && tokenPhase == 0) {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (context) => SecondRoute())
                // );
                Dialogs.materialDialog(
                    context: context,
                    barrierDismissible: false,
                    msg: "Come back here later to visit the sustainable t-shirt workplace!",
                    actions: [
                      IconsButton(
                        text: "Continue",
                        iconData: Icons.navigate_next,
                        color: Colors.blue,
                        textStyle: TextStyle(color: Colors.white),
                        iconColor: Colors.white,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ]
                );
              }
            },
          ),
          if (sd.nrGoodAnswers > 0) notificationDot(sd.nrGoodAnswers),
        ]),
      ),
    ]);
  }

  Container questionCard() {
    return Container(
      margin: EdgeInsets.only(top: 0.098 * sd.frameHeight(context)),
      height: 0.286 * sd.frameHeight(context),
      width: 0.826 * sd.frameWidth(context),
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
      child:
      Stack(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            height: 0.221 * sd.frameHeight(context),
            width: 0.795  * sd.frameWidth(context),
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
                    style: TextStyle(fontSize: sd.fontSize(context))
                ) : Text(
                    (correctlyAnswered ? "That is indeed " : "Actually, that is ") +
                        _currentQuestion.correctAnswer.toString() + ". " +
                        _currentQuestion.explanation + "\n",
                    style: TextStyle(fontSize: sd.fontSize(context))
                ),
              )
            ),
          ),
        ),

        Column(children: <Widget>[
          Spacer(),
          Padding(
            padding: EdgeInsets.all(0.007 * sd.frameHeight(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showingQuestion) Container(
                  margin: EdgeInsets.fromLTRB(10,0,10,0),
                  child: new ElevatedButton(
                    child: Text('True', style: TextStyle(fontSize: sd.fontSize(context)),),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                    ),
                    onPressed: () {
                      answerQuestion(true);
                    },
                  ),
                ),
                if (showingQuestion) Container(
                  margin: EdgeInsets.fromLTRB(10,0,10,0),
                  child: new ElevatedButton(
                    child: Text('False', style: TextStyle(fontSize: sd.fontSize(context)),),
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
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: sd.fontSize(context),
                        color: !showingAnimation && tokenPhase == 0
                            ? Colors.white
                            : Color.fromRGBO(180, 180, 180, 1)
                      ),
                    ),
                    style: ButtonStyle(
                        backgroundColor: !showingAnimation && tokenPhase == 0
                            ? MaterialStateProperty.all(Color.fromRGBO(50, 50, 50, 1))
                            : MaterialStateProperty.all(Color.fromRGBO(100, 100, 100, 1))
                    ),
                    onPressed: () {
                      if (!showingAnimation && tokenPhase == 0) continueAfterAnswer();
                    },
                  ),
                ),
              ],
            ),
          ),
        ]),
      ])
    );
  }

  Stack earth() {
    return Stack(
      children: [
        if (sd.nrWrongAnswers < sd.nrDisasters) Image.asset(
          "images/stills1/" + (sd.nrWrongAnswers).toString() + ".png",
          fit: BoxFit.fitHeight,
        ),
        if (showingAnimation)
          FutureBuilder(
            future: _initializedVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                );
              } else {
                return Center();
              }
            },
          ),
      ],
    );
  }

  AnimatedPositioned tokenAnimation() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
      width: (tokenPhase == 1) ? 0.111 * sd.frameHeight(context) : 0,
      bottom: (tokenPhase == 2) ? 45 : 90,
      right: (tokenPhase == 2) ? 45 : 20,
      child: Image.asset(
        "images/tokens/example-token-" + (sd.nrGoodAnswers + 1).toString() + ".png",
        fit: BoxFit.fitHeight,
      ),
    );
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
      setState(() {
        tokenPhase = 1;
      });
      Future.delayed(const Duration(milliseconds: 1200), () {
        setState(() {
          tokenPhase = 2;
        });

        Future.delayed(const Duration(milliseconds: 1000), () {
          tokenPhase = 0;
          sd.goodAnswer();
          if (sd.nrGoodAnswers == sd.nrDisasters) {
            Dialogs.materialDialog(
                context: context,
                barrierDismissible: false,
                title: "Earth is saved!",
                msg: "You did it, you saved earth! Your sustainable choices have" +
                    "prevented the earth from being destroyed. Thanks for that!" +
                    "\n\nYou can of course always play again to learn even more.",

                actions: [
                  IconsButton(
                    text: "Play again",
                    iconData: Icons.refresh,
                    color: Colors.blue,
                    textStyle: TextStyle(color: Colors.white),
                    iconColor: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop();
                      restartGame();
                    },
                  )
                ]
            );
          } else {
            nextQuestion();
          }
        });
      });
    } else {
      setState(() {
        showingAnimation = true;
        _videoController.play();
        _videoController.pause();
        _videoController.play();
      });

      precacheImage(new AssetImage(
          "images/stills1/" + (sd.nrWrongAnswers+1).toString() + ".png"),
          context);
      int delayTime = 1000 * (sd.animationDuration[sd.nrWrongAnswers] + 1);
      Future.delayed(Duration(milliseconds: delayTime), () {
        sd.wrongAnswer();
        if (sd.nrWrongAnswers == 1) {
          Dialogs.materialDialog(
              context: context,
              barrierDismissible: false,
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
                    continueAfterWrongAnswer();
                  },
                )
              ]
          );
        } else {
          setState(() {
            continueAfterWrongAnswer();
          });
        }
      });

    }
  }

  void continueAfterWrongAnswer() {
    if (sd.nrWrongAnswers < sd.nrDisasters) {
      _videoController = new VideoPlayerController.asset(
        "animations/screen1/" + (sd.nrWrongAnswers + 1).toString() + ".mp4",
      );
      _initializedVideoPlayerFuture = _videoController.initialize();
      _videoController.setLooping(false);
      nextQuestion();
    } else {
      Dialogs.materialDialog(
          context: context,
          barrierDismissible: false,
          title: "Well, there goes planet earth...",
          msg: "It sure was fun while it lasted, but the earth is no more. " +
              "Your choices have ultimately destroyed our planet and everything on it.",
          actions: [
            IconsButton(
              text: "Try again",
              iconData: Icons.refresh,
              color: Colors.blue,
              textStyle: TextStyle(color: Colors.white),
              iconColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
                restartGame();
              },
            )
          ]
      );
    }
  }

  restartGame() {
    sd.restartGame();
    continueAfterWrongAnswer();
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