import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_admob/firebase_admob.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner : false,
      home: Snakeo(),
    );
  }
}

class Snakeo extends StatefulWidget {
  @override
  _SnakeoState createState() => _SnakeoState();
}

class _SnakeoState extends State<Snakeo> {
  final int squaresPerRow = 20;
  final int squaresPerCol = 40;
  final fontStyle = TextStyle(color: Colors.white, fontSize: 20);
  final randomGen = Random();

  var snake = [
    [0, 0],
    [0, 1]
  ];
  var food = [0, 2];
  var direction = 'up';
  var isPlaying = false;
  bool start = false;
  AudioPlayer player = AudioPlayer();
  
  InterstitialAd ad(){
    return InterstitialAd(adUnitId: 'ca-app-pub-3940256099942544/1033173712');
  }
  @override
  void initState() {
    player.setUrl('audio/play.mp4');
    super.initState();
  }

  
  void startGame() {
    

    snake = [ // Snake head
      [(squaresPerRow / 2).floor(), (squaresPerCol / 2).floor()]
    ];

    snake.add([snake.first[0], snake.first[1]+1]); // Snake body

    createFood();

    isPlaying = true;
    /*if(isPlaying){
    AssetsAudioPlayer.newPlayer().open(
        Audio("audio/play.mp4"),
        //autoPlay: true,
        //showNotification: true,
        );
    }else{
      AssetsAudioPlayer.newPlayer().stop();
    }*/
    Timer.periodic(Duration(milliseconds: 300 - ((snake.length - 2) * 20)), (Timer timer) {
      print(Duration(milliseconds: 300 - ((snake.length - 2) * 20)).toString());
      moveSnake();
      if (checkGameOver()) {
        timer.cancel();
        ad();
        endGame();
      }
    });
  }

  void moveSnake() {
    setState(() {
      switch(direction) {
        case 'up':
          snake.insert(0, [snake.first[0], snake.first[1] - 1]);
          break;
        
        case 'down':
          snake.insert(0, [snake.first[0], snake.first[1] + 1]);
          break;

        case 'left':
          snake.insert(0, [snake.first[0] - 1, snake.first[1]]);
          break;

        case 'right':
          snake.insert(0, [snake.first[0] + 1, snake.first[1]]);
          break;
      }

      if (snake.first[0] != food[0] || snake.first[1] != food[1]) {
        snake.removeLast();
      } else {
        createFood();
      }
    });
  }

  void createFood() {
    food = [
      randomGen.nextInt(squaresPerRow),
      randomGen.nextInt(squaresPerCol)
    ];
  }

  bool checkGameOver() {
    if (!isPlaying
      //|| snake.first[1] < 0
      //|| snake.first[1] >= squaresPerCol
      //|| snake.first[0] < 0
      //|| snake.first[0] > squaresPerRow
    ) {
      return true;
    }

    if(snake.first[1] < 0){
      snake.first[1] = squaresPerCol;
    }else if(snake.first[0] < 0){
      snake.first[0] = squaresPerRow;
    }else if(snake.first[0] >= squaresPerRow){
      snake.first[0] = 0;
    }else if(snake.first[1] >= squaresPerCol){
      snake.first[1] = 0;
    }

    for(var i=1; i < snake.length; ++i) {
      if (snake[i][0] == snake.first[0] && snake[i][1] == snake.first[1]) {
        return true;
      }
    }

    return false;
  }

  void endGame() {
    isPlaying = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text(
            'Score: ${snake.length - 2}',
            style: TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Snakeo",
          style: TextStyle(
            color: Colors.black,
            fontSize: 30.0,
            letterSpacing: 1.0   
          )
        ),
        centerTitle: true,
        actions: <Widget>[
          start == false ? IconButton(
            onPressed: (){
              startGame();
              player.play('play.mp4');
              start = true;
            },
            color: Colors.black,
            iconSize: 30.0,
            icon: Icon(Icons.play_arrow),
          ) :
          IconButton(
            onPressed: (){
              endGame();
              player.stop();
              start = false;
            },
            color: Colors.black,
            iconSize: 30.0,
            icon: Icon(Icons.stop),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 35.0,),
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },
              child: AspectRatio(
                aspectRatio: squaresPerRow / (squaresPerCol + 5),
                child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: squaresPerRow,
                    ),
                    itemCount: squaresPerRow * squaresPerCol,
                    itemBuilder: (BuildContext context, int index) {
                      var color;
                      var x = index % squaresPerRow;
                      var y = (index / squaresPerRow).floor();

                      bool isSnakeBody = false;
                      for (var pos in snake) {
                        if (pos[0] == x && pos[1] == y) {
                          isSnakeBody = true;
                          break;
                        }
                      }

                      if (snake.first[0] == x && snake.first[1] == y) {
                        color = Colors.green;
                      } else if (isSnakeBody) {
                        color = Colors.green[200];
                      } else if (food[0] == x && food[1] == y) {
                        color = Colors.red;
                      } else {
                        color = Colors.grey[800];
                      }

                      return Container(
                        margin: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton(
                      color: isPlaying ? Colors.red : Colors.blue,
                      child: Text(
                        isPlaying ? 'End' : 'Start',
                        style: fontStyle,
                      ),
                      onPressed: () {
                          if(isPlaying) {
                            endGame();
                            player.stop();
                          }
                          else {
                            startGame();
                            player.play('play.mp4');
                          }
                      }),
                  Text(
                    'Score: ${snake.length - 2}',
                    style: fontStyle,
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
