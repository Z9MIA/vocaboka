import 'package:flutter/material.dart';
import 'package:vocaboka/src/details.dart';
import 'package:vocaboka/src/home.dart';
import 'package:vocaboka/src/repository/sql_database.dart';

void main() {
  // Firebase widget binding
  WidgetsFlutterBinding.ensureInitialized();
  SqlDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Vocaboka',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        initialRoute: "/",
        routes: {
          "/": (context) => HomeScreen(title: '보카보까 \u{1F440}'),
        });
  }
}
