import 'dart:async';

import 'package:flutter/material.dart';
import 'package:text_regnization/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 2),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffa8c4eb),
      body: Center(
        child: Image.asset("assets/images/splash.jpg"),
      ),
      bottomSheet: Container(
        height: 50,
        color: Color(0xfffa8c4eb),
        child: Center(
          child: Text(
            "ML Text Recognition",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 12),
          ),
        ),
      ),
    );
  }
}
