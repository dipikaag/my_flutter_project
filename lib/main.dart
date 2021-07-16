import 'package:flutter/material.dart';

import 'game.dart';
import 'dart:io';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Food',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/game_page':(context) => GamePage(),
      },
    );
  }
}
class HomePage extends StatefulWidget {
  //const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.lightGreen,
          title: new Text('Snake Food 🐍'),
        ),
        body: Container(
          child:
          DecoratedBox(
            decoration:  BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("images/—Pngtree—snake_2282821.png"),
                fit: BoxFit.fill,

              ),
            ),
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/game_page');
                  },
                  child: Text('Start'),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                      textStyle:
                      TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: double.infinity, height: 30),
                ElevatedButton(
                  onPressed: () => exit(0),
                  child: Text('Exit'),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.pink,
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 2),
                      textStyle:
                      TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),

        )
    );
  }
}

