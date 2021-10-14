// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SecondRoute())
                ).then((value) {
                  if (sd.completed) restartGame();
                });
                // Dialogs.materialDialog(
                //     context: context,
                //     barrierDismissible: false,
                //     msg: "Come back here later to visit the sustainable t-shirt workplace!",
                //     actions: [
                //       IconsButton(
                //         text: "Continue",
                //         iconData: Icons.navigate_next,
                //         color: Colors.blue,
                //         textStyle: TextStyle(color: Colors.white),
                //         iconColor: Colors.white,
                //         onPressed: () {
                //           Navigator.of(context).pop();
                //         },
                //       )
                //     ]
                // );
              }
            },
          ),
          if (sd.nrGoodAnswers > 0)
            notificationDot(sd.nrGoodAnswers + (tokenPhase == 2 ? 1 : 0)),
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
                    (correctlyAnswered ? "That is indeed " : "This is actually ") +
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
                        color: !showingAnimation && tokenPhase == 0 && sd.nrGoodAnswers < 10
                            ? Colors.white
                            : Color.fromRGBO(180, 180, 180, 1)
                      ),
                    ),
                    style: ButtonStyle(
                        backgroundColor: !showingAnimation && tokenPhase == 0 && sd.nrGoodAnswers < 10
                            ? MaterialStateProperty.all(Color.fromRGBO(50, 50, 50, 1))
                            : MaterialStateProperty.all(Color.fromRGBO(100, 100, 100, 1))
                    ),
                    onPressed: () {
                      if (!showingAnimation && tokenPhase == 0 && sd.nrGoodAnswers < 10) continueAfterAnswer();
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
      height: (tokenPhase == 1) ? 0.111 * sd.frameHeight(context) : 0,
      bottom: (tokenPhase == 1) ? 90 : 45,
      right: (tokenPhase == 1) ? 20 : 45,
      child: Stack (
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: (tokenPhase > 0) ? sd.offWhite : Color.fromRGBO(0, 0, 0, 0),
              border: (tokenPhase > 0) ? Border.all(
                color: sd.offWhite,
              ) : null,
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
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Image.asset(
              "images/tokens/token-" + (sd.nrGoodAnswers + 1).toString() + ".png",
              fit: BoxFit.fitHeight,
            ),
          ),
        ],
      )
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
      Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() {
          tokenPhase = 2;
        });

        Future.delayed(const Duration(milliseconds: 1000), () {
          sd.goodAnswer();
          tokenPhase = 0;
          if (sd.nrGoodAnswers == sd.nrDisasters) {
            Dialogs.materialDialog(
                context: context,
                barrierDismissible: false,
                title: "Great job!",
                msg: "Your sustainable choices have prevented the earth from "
                    "being destroyed. Thanks for that! Along the way, you have "
                    "collected all parts you need to make a T-shirt. It's time "
                    "to put those parts to good use!",

                actions: [
                  IconsButton(
                    text: "Continue to the workplace",
                    iconData: Icons.navigate_next,
                    color: Colors.blue,
                    textStyle: TextStyle(color: Colors.white),
                    iconColor: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SecondRoute())
                      ).then((value) {
                        if (sd.completed) restartGame();
                      });
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
    sd.completed = false;
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
  final SharedData sd = SharedData.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          // color: Colors.red,
          image: DecorationImage(
            image: AssetImage("images/screen2/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
              height: sd.frameHeight(context),
              width: sd.smallFrameWidth(context),
              child: StatefulSecondRoute(),
          ),
        ) /* add child content here */,
      ),
    );
  }
}

class StatefulSecondRoute extends StatefulWidget {
  //const StatefulSecondRoute({Key? key}) : super(key: key);

  @override
  State<StatefulSecondRoute> createState() => _StatefulSecondRouteState();
}

class _StatefulSecondRouteState extends State<StatefulSecondRoute> {
  SharedData sd = SharedData.instance;
  List placed;
  double dockedTokenSize;
  double tokenTargetSize;
  List<double> placedTokenSizes;

  VideoPlayerController _videoController;
  Future<void> _initializedVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    setState(() {
      _videoController = VideoPlayerController.asset(
        "animations/screen2/moving-workplace.mp4",
      );
      _initializedVideoPlayerFuture = _videoController.initialize();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!sd.hasVisitedSecondScreen) {
        Dialogs.materialDialog(
          context: context,
          barrierDismissible: false,
          title: "Welcome to the workplace",
          msg: "This workplace is for making T-shirts. Drag all your collected "
              "parts to the correct location to start the production.",
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
      setState(() {
        sd.hasVisitedSecondScreen = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    placed  = SharedData.instance.tokenPlacement;
    dockedTokenSize = 0.15 * sd.smallFrameWidth(context);
    tokenTargetSize = 0.045 * sd.frameHeight(context);
    placedTokenSizes = [
      sd.frameHeight(context) * 63.0 / 1080.0,
      sd.frameHeight(context) * 117.0 / 1080.0,
      sd.frameHeight(context) * 49.0 / 1080.0,
      sd.frameHeight(context) * 78.0 / 1080.0,
      sd.frameHeight(context) * 97.0 / 1080.0,
      sd.frameHeight(context) * 135.0 / 1080.0,
      sd.frameHeight(context) * 73.0 / 1080.0,
      sd.frameHeight(context) * 53.0 / 1080.0,
      sd.frameHeight(context) * 127.0 / 1080.0,
      sd.frameHeight(context) * 87.0 / 1080.0,
    ];

    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Image.asset(
            "images/screen2/workplace.png",
            fit: BoxFit.fitHeight,
          ),
        ),
        if (sd.completed) Align(
          alignment: Alignment.topCenter,
          child: FutureBuilder(
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
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: tokenDock(),
        ),
        if (!sd.completed) for (int i = 1; i <= 10; i++)
          completeTokenTarget(i),
        if (sd.nrGoodAnswers < 10) Positioned(
          top: 10,
          left: 10,
          child: MaterialButton(
            child:  Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 1.4 * sd.fontSize(context),
            ),
            height: 2.3 * sd.fontSize(context),
            minWidth: 2.3 * sd.fontSize(context),
            shape: CircleBorder(),
            color: Colors.green,
            elevation: 4.0,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        )
      ],
    );
  }

  Widget tokenDock() {
    return Container(
        width: 0.95 * sd.smallFrameWidth(context),
        height: 0.26 * sd.frameHeight(context),
        decoration: BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.15),
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0.05 * sd.smallFrameWidth(context)),
            topRight: Radius.circular(0.05 * sd.smallFrameWidth(context)),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int row = 0; row < 2; row++)
                Row (
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = row * 5 + 1; i <= (row + 1) * 5; i++)
                      dockedToken(i)
                  ],
                )
            ]
          ),
        )
    );
  }

  Widget dockedToken(int i) {
    if (!placed.contains(i) && SharedData.instance.nrGoodAnswers >= i)
      return Stack(
        children: [
          tokenDraggable(i, dockedTokenSize)
        ],
      );
    else
      return Container(width: dockedTokenSize, height: dockedTokenSize);
  }

  Widget completeTokenTarget(int i) {
    double topPadding = 0;
    double leftPadding = 0;
    double size = placedTokenSizes[i-1];

    switch(i) {
      case 1:
        topPadding = sd.frameHeight(context) * 101.0 / 1080.0;
        leftPadding = sd.smallFrameWidth(context) * 69.0 / 540.0;
        break;
      case 2:
        topPadding = sd.frameHeight(context) * 88.0 / 1080.0;
        leftPadding = sd.smallFrameWidth(context) * 110.0 / 540.0;
        break;
      case 3:
        topPadding = sd.frameHeight(context) * 180.0 / 1080.0;
        leftPadding = sd.smallFrameWidth(context) * 145.0 / 540.0;
        break;
      case 4:
        topPadding = sd.frameHeight(context) * 191.0 / 1080.0;
        leftPadding = sd.smallFrameWidth(context) * 200.0 / 540.0;
        break;
      case 5:
        topPadding = sd.frameHeight(context) * 92.0 / 1080.0;
        leftPadding = sd.smallFrameWidth(context) * 378.0 / 540.0;
        break;
      case 6:
        topPadding = sd.frameHeight(context) * 312.0 / 1080.0;
        leftPadding = sd.smallFrameWidth(context) * 48.0 / 540.0;
        break;
      case 7:
        topPadding = sd.frameHeight(context) * 467.0 / 1080.0;
        leftPadding = sd.smallFrameWidth(context) * 466.0 / 540.0;
        break;
      case 8:
        topPadding = sd.frameHeight(context) * 493.0 / 1080.0;
        leftPadding = sd.smallFrameWidth(context) * 264.0 / 540.0;
        break;
      case 9:
        topPadding = sd.frameHeight(context) * 473.0 / 1080.0;
        leftPadding = sd.smallFrameWidth(context) * 88.0 / 540.0;
        break;
      case 10:
        topPadding = sd.frameHeight(context) * 525.0 / 1080.0;
        leftPadding = sd.smallFrameWidth(context) * 78.0 / 540.0;
        break;
    }

    return Positioned(
        top: topPadding,
        left: leftPadding,
        child: Container(
          width: size,
          height: size,
          child: Stack(children: [
            Align(
              alignment: Alignment.center,
              child: tokenDragTarget(i, false),
            ),
            if (placed[i-1] > 0) Align(
              alignment: Alignment.center,
              child: tokenDraggable(placed[i-1], size),
            ),
            if (placed[i-1] > 0) Align(
              alignment: Alignment.center,
              child: tokenDragTarget(i, true),
            )
          ])
        )
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
        sd.tokenPlacement = placed;
        print(placed);
        if (listEquals(placed, [6, 5, 2, 10, 4, 1, 9, 7, 3, 8])) {
          setState(() {
            sd.completed = true;
            _videoController.play();
          });
          Future.delayed(const Duration(milliseconds: 41 * 1000), ()
          {
            setState(() {
              Dialogs.materialDialog(
                  context: context,
                  barrierDismissible: false,
                  title: "And that is how it's done!",
                  msg: "Not only have you saved earth, but more importantly, you "
                      "have created the most sustainably produced T-shirt ever! " +
                      "But there is of course always more to learn about " +
                      "sustainability. Play the game again to see new questions and learn even more.",
                  actions: [
                    IconsButton(
                      text: "Play again",
                      iconData: Icons.refresh,
                      color: Colors.blue,
                      textStyle: TextStyle(color: Colors.white),
                      iconColor: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pop(context);
                      },
                    )
                  ]
              );
            });
          });
        }
      },
    );
  }

  Draggable<int> tokenDraggable(int i, double size) {
    return new Draggable<int>(
      data: i,
      feedback: tokenContainer(i, size),
      child: tokenContainer(i, size),
      childWhenDragging: new Container(
        height: dockedTokenSize,
        width:  dockedTokenSize,
      ),
    );
  }

  Container tokenContainer(int i, double size) {
    return new Container(
      height: size,
      width:  size,
      decoration: new BoxDecoration(
        image: new DecorationImage(
            image: new AssetImage("assets/images/tokens/token-" + i.toString() + ".png"),
            fit: BoxFit.scaleDown
        ),
      ),
    );
  }

  Widget tokenTargetContainer(bool invisible) {
    if (invisible) {
      return Container(
        height: tokenTargetSize,
        width:  tokenTargetSize,
      );
    } else {
      return Container(
        height: tokenTargetSize,
        width:  tokenTargetSize,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromRGBO(0, 0, 0, 0.15),
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
      );
    }
  }
}