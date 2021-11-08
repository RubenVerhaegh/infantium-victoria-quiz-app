import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:myapp/SharedData.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:video_player/video_player.dart';

// This class contains all content for the second screen with the workplace
// and draggable tokens
class WorkplaceRouteParent extends StatelessWidget {
  final SharedData sd = SharedData.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/screen2/background.png"), // White paper
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            height: sd.frameHeight(context),
            width: sd.smallFrameWidth(context),
            child: WorkplaceRouteWidget(),
          ),
        ),
      ),
    );
  }
}

class WorkplaceRouteWidget extends StatefulWidget {
    @override
  State<WorkplaceRouteWidget> createState() => _WorkplaceRouteWidgetState();
}

/* The actual dynamic content of the second screen. It contains an image of
 * a workplace with that 10 circles on top of it to which the different parts
 * of the machinery can be dragged. These parts are referred to as "tokens" and
 * the circles are referred to as "drag targets" or "token targets". The number
 * of tokens that are shown to the user equals the number of correctly answered
 * questions so far. Each token is initially placed in the bottom section of the
 * screen, which is referred to as the "dock".
 */
class _WorkplaceRouteWidgetState extends State<WorkplaceRouteWidget> {
  SharedData sd = SharedData.instance;

  // Each entry in this list corresponds to a location where a token can be
  // placed (a drag target). The value of the i-th entry in this list indicates
  // which token is placed on the i-th drag target.
  List placed;

  // Size of a token that is not yet dragged to a drag target
  double dockedTokenSize;
  double tokenTargetSize;

  // Each drag target should display its token in a different size. This list
  // indicates for each drag target what that size should be.
  List<double> placedTokenSizes;

  // Whether all tokens are placed on the correct drag target
  bool ready = false;

  // Whether the image of the green button has been cached.
  bool imageCached = false;

  VideoPlayerController _videoController;
  Future<void> _initializedVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    setState(() {
      // Load final animation in the background
      _videoController = VideoPlayerController.asset(
        "animations/screen2/moving-workplace.mp4",
      );
      _initializedVideoPlayerFuture = _videoController.initialize();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If this is the first visit to this screen, display a dialog
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
    // Load how the tokens were placed when this screen was last visited
    placed  = SharedData.instance.tokenPlacement;

    dockedTokenSize = 0.15 * sd.smallFrameWidth(context);
    tokenTargetSize = 0.045 * sd.frameHeight(context);

    // Sizes that each of the 10 different drag targets should display its token
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
        // Image of (incomplete) workplace
        Align(
          alignment: Alignment.topCenter,
          child: Image.asset(
            "images/screen2/workplace.png",
            fit: BoxFit.fitHeight,
          ),
        ),

        // Token dock
        Align(
          alignment: Alignment.bottomCenter,
          child: tokenDock(),
        ),

        // Token targets
        for (int i = 1; i <= 10; i++)
          completeTokenTarget(i),

        // Red/green "Infantium Victoria" button
        Positioned(
          top: sd.frameHeight(context) * 614.0 / 929.0,
          left: sd.frameHeight(context) * 333.0 / 929.0,
          width: sd.frameHeight(context) * 133.0 / 929.0,
          height: sd.frameHeight(context) * 133.0 / 929.0,
          child: IconButton(
            icon: Image.asset("images/screen2/" +
                (ready ? "green" : "red") + "-button.png"),
            onPressed: () {
              // Button press when all tokens are placed correctly:
              // Play the final animation and show a dialog afterwards.
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

              // Button press when the tokens are not yet placed correctly:
              // Show dialog
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

        // Final animation (fades in when it starts)
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

        // Button in top left corner to go back to first screen.
        // This button is hidden when all tokens have been collected.
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

  // The dock: the bottom section of the screen where all tokens are displayed
  // initially.
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

        // The dock itself can be seen as drag target as tokens can be
        // dragged onto it.
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
            setState(() {
              for (int j = 0; j < placed.length; j++) {
                if (placed[j] == data) {
                  placed[j] = 0;
                }
              }
            });
            sd.tokenPlacement = placed;
            if (tokensPlacedCorrectly()) {
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

  bool tokensPlacedCorrectly() {
    return listEquals(placed, [6, 5, 2, 10, 4, 1, 9, 7, 3, 8]);
  }

  // A token that is still in the dock
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

  // A complete token target is a stack of three different things:
  // - Bottom: circle image which listens
  // - Middle: image of the token placed on this target (if there is any)
  // - Top:    invisible container also listening for dragged tokens
  //           (displayed over token in case token blocks the bottom one)
  Widget completeTokenTarget(int i) {
    double topPadding = 0;
    double leftPadding = 0;
    double size = placedTokenSizes[i-1];

    // Since each target displays its token in a different size, each target
    // has a different padding.
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
              // Visible drag target
              Align(
                alignment: Alignment.center,
                child: tokenDragTarget(i, false),
              ),

              // Token that is at this target
              if (placed[i-1] > 0) Align(
                alignment: Alignment.center,
                child: tokenDraggable(placed[i-1], size),
              ),

              // Invisible drag target in case this target has a token
              if (placed[i-1] > 0) Align(
                alignment: Alignment.center,
                child: tokenDragTarget(i, true),
              )
            ])
        )
    );
  }

  // A drag target listening for dragged items
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
        setState(() {
          for (int j = 0; j < placed.length; j++) {
            if (placed[j] == data) {
              placed[j] = 0;
            }
          }
          placed[i-1] = data;
        });
        sd.tokenPlacement = placed;
        if (tokensPlacedCorrectly()) {
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

  // Item that can be dragged across the screen
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

  // The image of the token that is displayed for a given tokenDraggable
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

  // The circle that is displayed for a given tokenDragTarget.
  // May be empty if this is an invisible target at the top of a
  // completeTokenTarget.
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