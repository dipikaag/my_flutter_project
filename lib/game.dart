import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';

import 'control_panel.dart';
import 'direction.dart';
import 'direction_type.dart';
import 'piece.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<Offset> positions = [];
  int length = 5;
  int step = 20;
  Direction direction = Direction.up;

  Piece food;
  Offset foodPosition;

  double screenWidth;
  double screenHeight;
  int lowerBoundX, upperBoundX, lowerBoundY, upperBoundY;

  Timer timer;
  double speed = 1;

  int score = 0;

  void draw() async {
    if (positions.length == 0) {
      positions.add(getRandomPositionWithinRange());
    }

    while (length > positions.length) {
      positions.add(positions[positions.length - 1]);
    }

    for (int i = positions.length - 1; i > 0; i--) {
      positions[i] = positions[i - 1];
    }
    positions[0] = await getNextPosition(positions[0]);
  }

  Direction getRandomDirection([DirectionType type]) {
    if (type == DirectionType.horizontal) {
      bool random = Random().nextBool();
      if (random) {
        return Direction.right;
      } else {
        return Direction.left;
      }
    } else if (type == DirectionType.vertical) {
      bool random = Random().nextBool();
      if (random) {
        return Direction.up;
      } else {
        return Direction.down;
      }
    } else {
      int random = Random().nextInt(4);
      return Direction.values[random];
    }
  }

  Offset getRandomPositionWithinRange() {
    int posX = Random().nextInt(upperBoundX) + lowerBoundX;
    int posY = Random().nextInt(upperBoundY) + lowerBoundY;
    return Offset(roundToNearestTens(posX).toDouble(),
        roundToNearestTens(posY).toDouble());
  }

  bool detectCollision(Offset position) {
    if (position.dx >= upperBoundX && direction == Direction.right) {
      return true;
    } else if (position.dx <= lowerBoundX && direction == Direction.left) {
      return true;
    } else if (position.dy >= upperBoundY && direction == Direction.down) {
      return true;
    } else if (position.dy <= lowerBoundY && direction == Direction.up) {
      return true;
    }

    return false;
  }

  void showGameOverDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.lightGreen,
                width: 5.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Game Over",
            style: TextStyle(color: Colors.green),
          ),
          content: Text(
            "Your game is over! But you played well. Your score is " +
                score.toString() +
                ".",
            style: TextStyle(color: Colors.green,fontSize: 20),
          ),
          actions: [
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  onPressed: (){
                    Navigator.of(context).pop();
                    restart();
                  },
                  child: Text(
                    "Restart",
                    style:
                        TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 120,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  onPressed: (){
                    Navigator.pushNamed(context, '/');
                  },
                  child: Text(
                    "Exit",
                    style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<Offset> getNextPosition(Offset position) async {
    Offset nextPosition;

    if (detectCollision(position) == true) {
      if (timer != null && timer.isActive) timer.cancel();
      await Future.delayed(
          Duration(milliseconds: 500), () => showGameOverDialog());
      return position;
    }

    if (direction == Direction.right) {
      nextPosition = Offset(position.dx + step, position.dy);
    } else if (direction == Direction.left) {
      nextPosition = Offset(position.dx - step, position.dy);
    } else if (direction == Direction.up) {
      nextPosition = Offset(position.dx, position.dy - step);
    } else if (direction == Direction.down) {
      nextPosition = Offset(position.dx, position.dy + step);
    }

    return nextPosition;
  }

  void drawFood() {
    if (foodPosition == null) {
      foodPosition = getRandomPositionWithinRange();
    }

    if (foodPosition == positions[0]) {
      length++;
      speed = speed + 0.25;
      score = score + 5;
      changeSpeed();

      foodPosition = getRandomPositionWithinRange();
    }

    food = Piece(
      posX: foodPosition.dx.toInt(),
      posY: foodPosition.dy.toInt(),
      size: step,
      color: Colors.tealAccent,
      isAnimated: true,
    );
  }

  List<Piece> getPieces() {
    List<Piece> pieces = [];
    draw();
    drawFood();

    for (int i = 0; i < length; ++i) {
      if (i >= positions.length) {
        continue;
      }

      pieces.add(
        Piece(
          posX: positions[i].dx.toInt(),
          posY: positions[i].dy.toInt(),
          size: step,
          color: Colors.tealAccent,
        ),
      );
    }

    return pieces;
  }

  Widget getControls() {
    return ControlPanel(
      onTapped: (Direction newDirection) {
        direction = newDirection;
      },
    );
  }

  int roundToNearestTens(int num) {
    int divisor = step;
    int output = (num ~/ divisor) * divisor;
    if (output == 0) {
      output += step;
    }
    return output;
  }

  void changeSpeed() {
    if (timer != null && timer.isActive) timer.cancel();

    // if you want timer to tick at fixed duration.
    timer = Timer.periodic(Duration(milliseconds: 200 ~/ speed), (timer) {
      setState(() {});
    });
  }

  Widget getScore() {
    return Positioned(
      top: 50.0,
      left: 40.0,
      child: Text(
        "Score: " + score.toString(),
        style: TextStyle(fontSize: 24.0,color: Colors.green[900]),
      ),
    );
  }

  void restart() {
    score = 0;
    length = 5;
    positions = [];
    direction = getRandomDirection();
    speed = 1;
    changeSpeed();
  }

  Widget getPlayAreaBorder() {
    return Positioned(
      top: lowerBoundY.toDouble(),
      left: lowerBoundX.toDouble(),
      child: Container(
        width: (upperBoundX - lowerBoundX + step).toDouble(),
        height: (upperBoundY - lowerBoundY + step).toDouble(),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.red[900].withOpacity(0.8),
            style: BorderStyle.values[1],
            width: 1.0,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    restart();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    lowerBoundX = step;
    lowerBoundY = step;
    upperBoundX = roundToNearestTens(screenWidth.toInt() - step);
    upperBoundY = roundToNearestTens(screenHeight.toInt() - step);

    return Scaffold(
      body: Container(
        color: Colors.red[400],
        child: Stack(
          children: [
            getPlayAreaBorder(),
            Container(
              child: Stack(
                children: getPieces(),
              ),
            ),
            food,
            getControls(),
            getScore(),
          ],
        ),
      ),
    );
  }
}
