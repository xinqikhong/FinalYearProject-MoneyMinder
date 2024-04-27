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
        primaryColor:
            const Color.fromARGB(255, 255, 147, 24), // Default primary color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 255, 227,
              186), // Default app bar background color // Default app bar text color
        ),
        buttonTheme: ButtonThemeData(
          buttonColor:
              const Color.fromARGB(255, 255, 147, 24), // Default button color
          textTheme: ButtonTextTheme.normal, // Default text theme for buttons
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: const Color.fromARGB(255, 255, 147, 24),
          ), // Default color scheme for buttons
        ),
        inputDecorationTheme: const InputDecorationTheme(
          // Set cursor color
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Color.fromARGB(255, 255, 227,
              186), width: 2.0), // Set border color and width
          ),
          labelStyle: TextStyle(color: Colors.grey),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.orange,
          selectionColor: Colors.orange,
          selectionHandleColor: Colors.orange,
        ),
        datePickerTheme:   const DatePickerThemeData(
          dividerColor: Colors.orange,
          surfaceTintColor: Colors.orange,
          backgroundColor: Colors.white, 
        ), 
        fontFamily: 'Montserrat',
        // Set your primary color here
      ),
      title: 'MyPFM',
      home: const SplashScreen(),
    );
  }
}
