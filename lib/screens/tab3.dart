import 'package:flutter/material.dart';

class BikeTab extends StatelessWidget {
  const BikeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.directions_bike, size: 100, color: Colors.red),
    );
  }
}