import 'package:flutter/material.dart';
import 'screens/tab1.dart';
import 'screens/tab2.dart';
import 'screens/tab3.dart';

void main() {
  runApp(const TabBarDemo());
}

class TabBarDemo extends StatelessWidget {
  const TabBarDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.directions_car)),
                Tab(icon: Icon(Icons.directions_transit)),
                Tab(icon: Icon(Icons.directions_bike)),
              ],
            ),
            title: const Text('ShowFOX🦊'),
          ),
          body: const TabBarView(
            children: [
              MusicalTab(),
              TransitTab(),
              BikeTab(),
            ],
          ),
        ),
      ),
    );
  }
}