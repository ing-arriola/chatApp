import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title:Center(child: Text('Jaime Arriola')),
          backgroundColor: Colors.blueGrey[900],),
        backgroundColor: Colors.blueGrey[400],
        body: Center(
          child: Image(
            image: AssetImage('images/diamond.png'),
          ),
        ),),
    ),
  );
}
