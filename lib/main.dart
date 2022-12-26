import 'dart:async';

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
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
  Widget _homeWidget = HomeScreen(title: '보카보까 \u{1F440}');
  StreamSubscription? _intentDataStreamSubscription;

  void setHomeWidget(String? text) {
    if (text?.isNotEmpty == true) {
      setState(() {
        _homeWidget = HomeScreen(
          title: '보카보까 \u{1F440}',
          initialValue: text,
        );
      });
    } else {
      setState(() {
        _homeWidget = HomeScreen(title: '보카보까 \u{1F440}');
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        setHomeWidget(value);
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    ReceiveSharingIntent.getInitialText().then((String? text) {
      if (text != null) {
        setState(() {
          setHomeWidget(text);
        });
      }
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: _homeWidget, theme: ThemeData(primarySwatch: Colors.deepPurple));
  }
}
