import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:myapp/SharedData.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:video_player/video_player.dart';
import 'Question.dart';
import 'WorkplaceRoute.dart';

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
  bool contentUnlocked = true;
  bool loginRetry = false;

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
    if (sd.firstTime && contentUnlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Dialogs.materialDialog(
            context: context,
            barrierDismissible: false,
            title: "Welcome to SEW WHAT?!",
            msg: "A game where you can save the world with fashion.",
            actions: [
              IconsButton(
                text: "Start!",
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
        setState(() {
          sd.firstTime = false;
        });
      });
    }
    return Center(
      child: Container(
        height: sd.frameHeight(context),
        width: sd.frameWidth(context),
        child: contentUnlocked
            ? firstScreenContent()
            : loginScreen(),
      ),
    );

  }

  Widget loginScreen() {
    TextEditingController loginController = new TextEditingController();
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              "Enter the password to continue:",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: sd.fontSize(context)
              )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 0.6 * sd.frameWidth(context),
                child: TextField(
                  controller: loginController,
                  style: TextStyle(fontSize: sd.fontSize(context)),
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(100)
                    ),
                    hintText: loginRetry
                        ? 'Try again'
                        : 'Password',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: MaterialButton(
                  child:  Icon(
                    Icons.send,
                    color: Colors.blue,
                  ),
                  height: 56,
                  minWidth: 56,
                  shape: CircleBorder(),
                  color: Colors.white,
                  elevation: 2.0,
                  onPressed: () {
                    var text = loginController.text;
                    if (text == sd.password) {
                      setState(() {
                        contentUnlocked = true;
                      });
                    } else {
                      setState(() {
                        loginRetry = true;
                      });
                    }
                  },
                ),
              )
            ],
          ),
        ],
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
    Color borderColor;
    if (showingQuestion) {
      borderColor = sd.offWhite;
    } else {
      borderColor = correctlyAnswered
          ? Colors.green
          : Colors.red;
    }

    bool continueButtonEnabled = !showingAnimation && tokenPhase == 0 && sd.nrGoodAnswers < 10;

    return Container(
        margin: EdgeInsets.only(top: 0.098 * sd.frameHeight(context)),
        height: 0.286 * sd.frameHeight(context),
        width: 0.826 * sd.frameWidth(context),
        decoration: BoxDecoration(
          color: sd.offWhite,
          border: Border.all(
            color: borderColor,
            width: 0.005 * sd.frameHeight(context),
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
                        _currentQuestion.question + "\n",
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
                    child: new ElevatedButton.icon(
                      icon: Icon(Icons.check, color: sd.enabledTextColor, size: sd.fontSize(context)),
                      label: Text('True',
                        style: TextStyle(
                          fontSize: sd.fontSize(context),
                          color: sd.enabledTextColor,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(sd.enabledButtonColor),
                      ),
                      onPressed: () {
                        answerQuestion(true);
                      },
                    ),
                  ),
                  if (showingQuestion) Container(
                    margin: EdgeInsets.fromLTRB(10,0,10,0),
                    child: new ElevatedButton.icon(
                      icon: Icon(Icons.close, color: sd.enabledTextColor, size: sd.fontSize(context)),
                      label: Text('False',
                        style: TextStyle(
                          fontSize: sd.fontSize(context),
                          color: sd.enabledTextColor,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(sd.enabledButtonColor),
                      ),
                      onPressed: () {
                        answerQuestion(false);
                      },
                    ),
                  ),
                  if(!showingQuestion) Container(
                    margin: EdgeInsets.all(0),
                    child: ElevatedButton.icon(
                      icon: Icon(
                          Icons.navigate_next,
                          color: continueButtonEnabled
                              ? sd.enabledTextColor
                              : sd.disabledTextColor,
                          size: sd.fontSize(context)
                      ),
                      label: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: sd.fontSize(context),
                          color: continueButtonEnabled
                              ? sd.enabledTextColor
                              : sd.disabledTextColor,
                        ),
                      ),
                      style: ButtonStyle(
                          backgroundColor: continueButtonEnabled
                              ? MaterialStateProperty.all(sd.enabledButtonColor)
                              : MaterialStateProperty.all(sd.disabledButtonColor)
                      ),
                      onPressed: () {
                        if (continueButtonEnabled) continueAfterAnswer();
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