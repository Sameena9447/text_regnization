import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String text;

  const ResultScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            'Result',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_circle_left_outlined,
                color: Colors.white,
              )),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(30.0),
            child: SelectableText(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        ),
      );
}
