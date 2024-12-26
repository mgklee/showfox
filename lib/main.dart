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
      appBar: AppBar(title: Text("Tab Example")),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Tab 1"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Tab 2"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tab 3"),
        ],
      ),
    );
  }
}
