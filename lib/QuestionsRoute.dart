import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:myapp/SharedData.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:video_player/video_player.dart';
import 'Question.dart';
import 'WorkplaceRoute.dart';

// This class contains all content for the first screen with the earth and
// question cards
class QuestionsRouteParent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 0, 0, 1),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: QuestionsRouteWidget(),
          )
        ],
      ),
    );
  }
}

class QuestionsRouteWidget extends StatefulWidget {
  @override
  _QuestionsRouteWidgetState createState() => _QuestionsRouteWidgetState();
}

// The actual dynamic content of the first screen
class _QuestionsRouteWidgetState extends State {
  SharedData sd = SharedData.instance;
  Question _currentQuestion = new Question("", true, "");
  bool showingQuestion = true;
  bool showingAnimation = false;
  bool correctlyAnswered;
  int tokenPhase = 0; // Variable to control animation of token collection
  bool contentUnlocked = true; // Whether the content of the app is unlocked
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
    // Show dialog upon first time opening
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

    // Show either login screen (if enabled) or the actual content of the app
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

  // Currently unused. This was previously used to block access to the content
  // until a password was added.
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
                child: TextField( // Password field
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
                child: MaterialButton( // Enter password button
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

  // Layout of the first screen
  Stack firstScreenContent() {
    return Stack(children: <Widget> [
      // Earth
      Align(
        alignment: Alignment.topCenter,
        child: earth(),
      ),

      // Question card
      Align(
        alignment: Alignment.topCenter,
        child: questionCard(),
      ),

      // Animation for when a new token is collected
      tokenAnimation(),

      // Button to go to workplace screen
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
                    MaterialPageRoute(builder: (context) => WorkplaceRouteParent())
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
    // The color of the border of the question card changes when a question is
    // answered correctly or wrongly.
    Color borderColor;
    if (showingQuestion) {
      borderColor = sd.offWhite;
    } else {
      borderColor = correctlyAnswered
          ? Colors.green
          : Colors.red;
    }

    // Whether the 'continue' button can be pressed
    bool continueButtonEnabled = !showingAnimation && tokenPhase == 0 && sd.nrGoodAnswers < 10;

    return Container( // Card shape
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
          Padding( // Darker "screen" on card containing the questions
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
              child: Scrollbar( // Scrollable question/answer text
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
            Spacer(), // Vertical space between question screen and button(s)
            Padding(
              padding: EdgeInsets.all(0.007 * sd.frameHeight(context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // "True" button
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

                  // "False" button
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

                  // "Continue" button
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

  // The images and animations of earth
  Stack earth() {
    return Stack(
      children: [
        // Image
        if (sd.nrWrongAnswers < sd.nrDisasters) Image.asset(
          "images/stills1/" + (sd.nrWrongAnswers).toString() + ".png",
          fit: BoxFit.fitHeight,
        ),

        // Video
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

  // Animated widget that is shown when the user receives a new token after
  // answering a question correctly. Tokens are the objects that can be dragged
  // in the second screen with the workplace.
  // The different stages of the animation are controlled via the `tokenPhase'
  // variable.
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
            // Background shape for token
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

            // Image of the newly collected token
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

  // Load and show the next question
  void nextQuestion() async {
    var newQuestion = await sd.randomQuestion();
    setState(() {
      showingQuestion = true;
      showingAnimation = false;
      _currentQuestion = newQuestion;
    });
  }

  // Collected logic for continuing after the user gives an answer
  void continueAfterAnswer() async {
    if (correctlyAnswered) {
      // Play the token animation when a question is answered correctly
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

          // When all tokens have been collected:
          if (sd.nrGoodAnswers == sd.nrTokens) {
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
                          MaterialPageRoute(builder: (context) => WorkplaceRouteParent())
                      ).then((value) {
                        if (sd.completed) restartGame();
                      });
                    },
                  )
                ]
            );
          } else {
            // When not all tokens are collected yet, simply continue with the
            // next question
            nextQuestion();
          }
        });
      });
    } else {
      // If the question is answered incorrectly, play the next animation
      setState(() {
        showingAnimation = true;
        _videoController.play();
        _videoController.pause();
        _videoController.play();
      });

      // Load the image of the next stage of the earth for when the animation
      // will end
      precacheImage(new AssetImage(
          "images/stills1/" + (sd.nrWrongAnswers+1).toString() + ".png"),
          context);
      int delayTime = 1000 * (sd.animationDuration[sd.nrWrongAnswers] + 1);
      Future.delayed(Duration(milliseconds: delayTime), () {
        sd.wrongAnswer();
        // Display dialog if this was the first incorrect answer
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
          // Otherwise, continue without showing the dialog
          setState(() {
            continueAfterWrongAnswer();
          });
        }
      });

    }
  }

  // Logic for when the animation stops playing after a wrong answer
  void continueAfterWrongAnswer() {
    // If the earth is not destroyed, load the next video in the background
    // and continue to the next question.
    if (sd.nrWrongAnswers < sd.nrDisasters) {
      _videoController = new VideoPlayerController.asset(
        "animations/screen1/" + (sd.nrWrongAnswers + 1).toString() + ".mp4",
      );
      _initializedVideoPlayerFuture = _videoController.initialize();
      _videoController.setLooping(false);
      nextQuestion();
    } else {
      // If the earth is destroyed, show a dialog
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

  // Resets the game to its initial state
  restartGame() {
    sd.completed = false;
    sd.restartGame();
    continueAfterWrongAnswer();
  }

  // Handle the "true"/"false" button press
  void answerQuestion(bool givenAnswer) {
    // Determine whether the question was answered correctly
    bool correct = (givenAnswer == _currentQuestion.correctAnswer);

    setState(() {
      correctlyAnswered = correct;
      showingQuestion = false;
    });
  }

  // This red "notification dot" keeps count of how many tokens have been
  // collected
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