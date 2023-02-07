import 'package:flutter/material.dart';
import 'package:vocaboka/src/home.dart';
import 'package:vocaboka/src/repository/sql_database.dart';


void main() {
  // Firebase widget binding
  WidgetsFlutterBinding.ensureInitialized();
  SqlDatabase();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: HomeScreen(), theme: ThemeData(primarySwatch: Colors.deepPurple),
    );
  }
}
