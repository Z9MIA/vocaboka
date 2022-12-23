import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.title});

  final String title;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 10),
            Text(widget.title, style: TextStyle(color: Colors.black))
          ],
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0.0,
      ),
    );
  }
}
