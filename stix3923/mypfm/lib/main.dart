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
        brightness: Brightness.light,
        primarySwatch: Colors.orange,
        primaryColor:
            const Color.fromARGB(255, 255, 115, 0), // Default primary color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          /*iconTheme: IconThemeData(
              color: Color.fromARGB(
                  255, 255, 115, 0) // Change this color to your desired color
              ), */ // Default app bar background color // Default app bar text color
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
            foregroundColor: const Color.fromARGB(255, 255, 115, 0),
            backgroundColor: const Color.fromARGB(
                255, 255, 255, 255), // Set your desired text color
            /*shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(18), // Adjust the border radius here
            ),*/ // Set text color for TextButtons
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor:
              Color.fromARGB(255, 255, 227, 186), // Set background color
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
        datePickerTheme: DatePickerThemeData(
          //headerBackgroundColor:Colors.orange, // Header background color
          dayBackgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.orange;
            }
            return null; // Use default color for non-selected days
          }),
          todayBackgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              //const BorderSide(color: Colors.orange);
              return Colors.orange;
            }
            return null; // Remove background color for today when not selected
          }), // Background color for today's date
          dayOverlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.orange.withOpacity(0.4);
            }
            return null; // Use default overlay color
          }),
          dividerColor: Colors.orange,
          surfaceTintColor: Colors.orange,
          backgroundColor: Colors.white,
        ),
        /*iconTheme: IconThemeData(
          color: Colors.orange, // Change this color to your desired color
        ),*/

        fontFamily: 'Montserrat',
        // Set your primary color here
      ),
      /*darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        primaryColor: const Color.fromARGB(255, 255, 115, 0),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 255, 115, 0),
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 255, 227, 186),
          foregroundColor: Colors.orange,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Color.fromARGB(255, 255, 227, 186), width: 2.0),
          ),
          labelStyle: TextStyle(color: Colors.grey),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.orange,
          selectionColor: Colors.orange,
          selectionHandleColor: Colors.orange,
        ),
        datePickerTheme: DatePickerThemeData(
          dayBackgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.orange;
            }
            return null;
          }),
          todayBackgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.orange;
            }
            return null;
          }),
          dayOverlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.orange.withOpacity(0.4);
            }
            return null;
          }),
          dividerColor: Colors.orange,
          surfaceTintColor: Colors.orange,
          backgroundColor: Colors.black,
        ),
        fontFamily: 'Montserrat',
      ),
      themeMode: ThemeMode.system,*/
      title: 'MyPFM',
      home: const SplashScreen(),
    );
  }
}
