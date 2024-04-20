import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mypfm/view/mainscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 5),
        () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (content) => const MainScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints.expand(),
          color: const Color.fromARGB(255, 255, 248, 199),
          // Set the background color here
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/images/pfm_logo1.png'),
              ),
              Text(
                "MoneyMinder",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              ),
              SizedBox(
                height: 10,
              ),
              CircularProgressIndicator(
                color: Colors.orangeAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
