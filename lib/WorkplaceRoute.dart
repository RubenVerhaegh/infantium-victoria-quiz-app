import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:myapp/SharedData.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:video_player/video_player.dart';

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

  bool ready = false;
  bool imageCached = false;

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
            msg: "A T-shirt will be made in this workplace. Drag all your collected "
                "parts to the correct location. Once everything is in the right place, the production will start.",
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
    if (sd.nrGoodAnswers == 10 && !imageCached) {
      if (sd.nrGoodAnswers == 10) {
        precacheImage(new AssetImage(
            "images/screen2/green-button.png"),
            context);
        imageCached = true;
      }
    }

    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Image.asset(
            "images/screen2/workplace.png",
            fit: BoxFit.fitHeight,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: tokenDock(),
        ),
        for (int i = 1; i <= 10; i++)
          completeTokenTarget(i),
        Positioned(
          top: sd.frameHeight(context) * 614.0 / 929.0,
          left: sd.frameHeight(context) * 333.0 / 929.0,
          width: sd.frameHeight(context) * 133.0 / 929.0,
          height: sd.frameHeight(context) * 133.0 / 929.0,
          child: IconButton(
            icon: Image.asset("images/screen2/" +
                (ready ? "green" : "red") + "-button.png"),
            onPressed: () {
              if (ready) {
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
              } else {
                Dialogs.materialDialog(
                    context: context,
                    barrierDismissible: false,
                    title: "Place all items in the correct location",
                    msg: "Once all items are in the right place, this button "
                        "will turn green. Then, the production can begin.",
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
        ),
        AnimatedOpacity(
          opacity: sd.completed ? 1.0 : 0.0,
          duration: new Duration(milliseconds: 1000),
          child: (sd.completed) ? Align(
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
          ) : Container(),
        ),
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
    return Stack(
      children: [
        Container(
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
        ),
        DragTarget<int>(
          builder: (
              BuildContext context,
              List<dynamic> accepted,
              List<dynamic> rejected,
              ) {
            return Container(
              width: 0.95 * sd.smallFrameWidth(context),
              height: 0.26 * sd.frameHeight(context),
            );
          },
          onAccept: (int data) {
            print("dragged " + data.toString() + " to the dock");
            setState(() {
              for (int j = 0; j < placed.length; j++) {
                if (placed[j] == data) {
                  placed[j] = 0;
                }
              }
            });
            sd.tokenPlacement = placed;
            print(placed);
            if (listEquals(placed, [6, 5, 2, 10, 4, 1, 9, 7, 3, 8])) {
              setState(() {
                ready = true;
              });
            } else if (ready = true) {
              setState(() {
                ready = false;
              });
            }
          },
        ),
      ],
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
            ready = true;
          });
        } else if (ready = true) {
          setState(() {
            ready = false;
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
            image: new AssetImage("images/tokens/token-" + i.toString() + ".png"),
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