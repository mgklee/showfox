import 'package:flutter/material.dart';

class TransitTab extends StatelessWidget {
  const TransitTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.directions_transit, size: 100, color: Colors.green),
    );
  }
}