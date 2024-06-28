import 'package:flutter/material.dart';
import 'package:mypfm/view/currency_provider.dart';
import 'package:mypfm/view/splashscreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CurrencyProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        dividerColor: Color.fromARGB(255, 255, 115, 0),
        brightness: Brightness.light,
        //primarySwatch: Colors.orange,
        primaryColor: Color.fromARGB(255, 255, 115, 0), // Default primary color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color.fromARGB(255, 255, 115, 0),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 255, 227, 186),
          foregroundColor: Color.fromARGB(255, 255, 115, 0),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 255, 227, 186), width: 2.0),
          ),
          labelStyle: TextStyle(color: Colors.grey),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color.fromARGB(255, 255, 115, 0),
          selectionColor: Color.fromARGB(255, 255, 115, 0),
          selectionHandleColor: Color.fromARGB(255, 255, 115, 0),
        ),
        datePickerTheme: DatePickerThemeData(
          dayBackgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Color.fromARGB(255, 255, 115, 0);
              }
              return null;
            },
          ),
          todayBackgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Color.fromARGB(255, 255, 115, 0);
              }
              return null;
            },
          ),
          dayOverlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Color.fromARGB(255, 255, 115, 0).withOpacity(0.4);
              }
              return null;
            },
          ),
          surfaceTintColor: Color.fromARGB(255, 255, 115, 0),
          backgroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.light(
          primary: Color.fromARGB(255, 255, 115, 0),
          onPrimary: Colors.white,
          secondary: Color.fromARGB(255, 255, 115, 0),
          onSecondary: Colors.white,
        ),
        fontFamily: 'Montserrat',
      ),
      darkTheme: ThemeData(
        dividerColor: Color.fromARGB(255, 255, 115, 0),
        brightness: Brightness.dark,
        //primarySwatch: Colors.orange,
        primaryColor: Color.fromARGB(255, 255, 115, 0),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color.fromARGB(255, 255, 115, 0),
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 255, 227, 186),
          foregroundColor: Color.fromARGB(255, 255, 115, 0),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 255, 227, 186), width: 2.0),
          ),
          labelStyle: TextStyle(color: Colors.grey),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color.fromARGB(255, 255, 115, 0),
          selectionColor: Color.fromARGB(255, 255, 115, 0),
          selectionHandleColor: Color.fromARGB(255, 255, 115, 0),
        ),
        datePickerTheme: DatePickerThemeData(
          dayBackgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Color.fromARGB(255, 255, 115, 0);
              }
              return null;
            },
          ),
          todayBackgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Color.fromARGB(255, 255, 115, 0);
              }
              return null;
            },
          ),
          dayOverlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Color.fromARGB(255, 255, 115, 0).withOpacity(0.4);
              }
              return null;
            },
          ),
          surfaceTintColor: Color.fromARGB(255, 255, 115, 0),
          backgroundColor: Colors.black,
        ),
        colorScheme: ColorScheme.dark(
          primary: Color.fromARGB(255, 255, 115, 0),
          onPrimary: Colors.white,
          secondary: Color.fromARGB(255, 255, 115, 0),
          onSecondary: Colors.white,
        ),
        fontFamily: 'Montserrat',
      ),
      themeMode: ThemeMode.system,
      title: 'MyPFM',
      home: const SplashScreen(),
    );
  }
}

