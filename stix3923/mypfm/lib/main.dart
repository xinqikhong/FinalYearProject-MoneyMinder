import 'package:flutter/material.dart';
import 'package:mypfm/view/currency_provider.dart';
import 'package:mypfm/view/splashscreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider<CurrencyProvider>(
    create: (context) => CurrencyProvider(), // Create a new CurrencyProvider instance
    child: MyApp(), // Replace with your actual main app widget
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        // ... existing delegates
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.orange,
        primaryColor:
            const Color.fromARGB(255, 255, 147, 24), // Default primary color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 255, 245,
              230), // Default app bar background color // Default app bar text color
        ),
        /*buttonTheme: ButtonThemeData(
          buttonColor:
              const Color.fromARGB(255, 255, 147, 24), // Default button color
          textTheme: ButtonTextTheme.normal, // Default text theme for buttons
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: const Color.fromARGB(255, 255, 147, 24),
          ), // Default color scheme for buttons
        ),*/
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(
                255, 240, 101, 1), // Set text color for TextButtons
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor:
              Color.fromARGB(255, 255, 211, 154), // Set background color
          foregroundColor: Colors.orange, // Set icon color
        ),

        inputDecorationTheme: const InputDecorationTheme(
          // Set cursor color
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Color.fromARGB(255, 255, 227, 186),
                width: 2.0), // Set border color and width
          ),
          labelStyle: TextStyle(color: Colors.grey),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.orange,
          selectionColor: Colors.orange,
          selectionHandleColor: Colors.orange,
        ),
        datePickerTheme: const DatePickerThemeData(
          dividerColor: Colors.orange,
          surfaceTintColor: Colors.orange,
          backgroundColor: Colors.white,
        ),
        iconTheme: const IconThemeData(
          // Set icon theme for AppBar
          //color: Color.fromARGB(255, 240, 101, 1), // Set icon color to orange
        ),
        
        fontFamily: 'Montserrat',
        // Set your primary color here
      ),
      title: 'MyPFM',
      home: const SplashScreen(),
    );
  }
}
