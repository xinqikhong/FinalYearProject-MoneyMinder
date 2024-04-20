import 'package:flutter/material.dart';
import 'package:mypfm/view/splashscreen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Light mode theme properties
          brightness: Brightness.light,
          primaryColor: Colors.orange.shade300, // Example primary color
        ),
        darkTheme: ThemeData.dark().copyWith(
          // Dark mode theme properties
          primaryColor:
              Colors.orange.shade600, // Example primary color in dark mode
        ),
        title: 'MyPFM',
        home: const Scaffold(
          body: SplashScreen(),
        ));
  }
}
