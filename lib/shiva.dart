import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:objectbox_note_app/note_model.dart'; // Import your Note model

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Store _store = Store(getObjectBoxModel());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ObjectBox Note App',
      home: MyHomePage(store: _store),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Store store;

  MyHomePage({required this.store});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}