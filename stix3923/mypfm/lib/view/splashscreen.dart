import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/model/user.dart';
import 'package:mypfm/view/mainscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:mypfm/view/currency_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAndLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints.expand(),
          //color: Color.fromARGB(255, 255, 255, 255),
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
              /*SizedBox(
                height: 10,
              ),
              CircularProgressIndicator(
                color: Colors.orangeAccent,
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  checkAndLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = (prefs.getString('email')) ?? '';
    String password = (prefs.getString('pass')) ?? '';
    late User user;
    if (email.length > 1 && password.length > 1) {
      http.post(Uri.parse("${MyConfig.server}/mypfm/php/login_user.php"),
          body: {"email": email, "password": password}).then((response) {
        print(response.body);
        var jsondata = jsonDecode(response.body);
        if (response.statusCode == 200 && jsondata['status'] == 'success') {
          User user = User.fromJson(jsondata['data']);
          final currencyProvider =
              Provider.of<CurrencyProvider>(context, listen: false);
          currencyProvider.setUserId(user.id);
          Timer(
              const Duration(seconds: 5),
              () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (content) => MainScreen(user: user, currencyProvider: Provider.of<CurrencyProvider>(context, listen: false)))));
        } else {
          user = User(
            id: "unregistered",
            name: "unregistered",
            email: "unregistered",
            regdate: "unregistered",
            otp: "unregistered",
            phone: "unregistered",
            address: "unregistered",
            passtoken: "unregistered"
          );

          Timer(
              const Duration(seconds: 3),
              () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (content) => MainScreen(user: user, currencyProvider: Provider.of<CurrencyProvider>(context, listen: false)))));
        }
      }).timeout(const Duration(seconds: 5));
    } else {
      user = User(
        id: "unregistered",
        name: "unregistered",
        email: "unregistered",
        regdate: "unregistered",
        otp: "unregistered",
        phone: "unregistered",
        address: "unregistered",
        passtoken: "unregistered"
      );
      Timer(
          const Duration(seconds: 3),
          () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (content) => MainScreen(user: user, currencyProvider: Provider.of<CurrencyProvider>(context, listen: false)))));
    }
  }
}
