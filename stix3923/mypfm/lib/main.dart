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
        brightness: Brightness.light,
        primaryColor: Color.fromARGB(255, 255, 147, 24), // Default primary color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 255, 227, 186), // Default app bar background color // Default app bar text color
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color.fromARGB(255, 255, 147, 24), // Default button color
          textTheme: ButtonTextTheme.normal, // Default text theme for buttons
          colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: Color.fromARGB(255, 255, 147, 24),), // Default color scheme for buttons
        ), // Set the background color to white
        fontFamily: 'Montserrat',
        // Set your primary color here
      ),
      title: 'MyPFM',
      home: SplashScreen(),
    );
  }
}
