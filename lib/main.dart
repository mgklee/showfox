import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/tab1.dart';
import 'screens/tab2.dart';
import 'screens/tab3.dart';
import 'musical.dart';
import 'actor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures async operations work before runApp

  // Load data from JSON files
  final String musicalJson = await rootBundle.loadString('assets/musical.json');
  final List<dynamic> musicalData = json.decode(musicalJson);
  final List<Musical> musicals = musicalData.map((item) => Musical.fromJson(item)).toList();

  final String actorJson = await rootBundle.loadString('assets/actor.json');
  final List<dynamic> actorData = json.decode(actorJson);
  final List<Actor> actors = actorData.map((item) => Actor.fromJson(item)).toList();

  runApp(MyApp(musicals: musicals, actors: actors));
}

class MyApp extends StatelessWidget {
  final List<Musical> musicals;
  final List<Actor> actors;

  const MyApp({super.key, required this.musicals, required this.actors});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: HomePage(musicals: musicals, actors: actors),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<Musical> musicals;
  final List<Actor> actors;

  const HomePage({super.key, required this.musicals, required this.actors});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _tabs = [
      Tab1(
        musicals: widget.musicals,
        actors: widget.actors,
      ),
      Tab2(
        musicals: widget.musicals,
        actors: widget.actors,
      ),
      Tab3(),
    ];

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "🦊ShowFOX",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.orangeAccent
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.orangeAccent,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.deepOrange,
        // unselectedIconTheme: IconThemeData(color: Colors.white),
        // selectedIconTheme: IconThemeData(color: Colors.deepOrange),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: "Musicals"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Actors"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: "Schedules"
          ),
        ],
      ),
    );
  }
}
