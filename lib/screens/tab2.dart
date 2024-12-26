import 'package:flutter/material.dart';

class Tab2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      height: 200,
      color: Colors.blue,
      child: Center(
        child: Text(
          '김소현',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
