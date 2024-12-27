import 'package:flutter/material.dart';
import 'screens/tab1.dart';
import 'screens/tab2.dart';
import 'screens/tab3.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // 각 탭의 화면
  final List<Widget> _tabs = [
    Tab1(), // tab1.dart의 클래스
    Tab2(), // tab2.dart의 클래스
    Tab3(), // tab3.dart의 클래스
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("🦊ShowFOX"), backgroundColor: Colors.orangeAccent),
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "musicals"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "actors"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: "schedules"),
        ],
      ),
    );
  }
}
