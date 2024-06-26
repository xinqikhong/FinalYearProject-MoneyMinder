import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/model/user.dart';
import 'package:mypfm/view/currency_provider.dart';
import 'package:mypfm/view/forgotpasswordscreen.dart';
import 'package:mypfm/view/registerscreen.dart';
//import 'package:mypfm/view/resetpasswordscreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
//import 'package:ndialog/ndialog.dart';
import 'package:mypfm/view/customprogressdialog.dart';
import 'mainscreen.dart';

//typedef VoidCallback = void Function();

class LoginScreen extends StatefulWidget {
  //final VoidCallback clearPreferencesCallback;
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late double screenHeight, screenWidth, resWidth;
  final focus = FocusNode();
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final TextEditingController _emailditingController = TextEditingController();
  final TextEditingController _passEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isChecked = false;
  bool _passwordVisible = true;

  @override
  void initState() {
    super.initState();
    loadPref();
    focus.attach(context);
    focus1.attach(context);
    focus2.attach(context);
  }

  @override
  void dispose() {
    focus.dispose();
    focus1.dispose();
    focus2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth <= 600) {
      resWidth = screenWidth;
    } else {
      resWidth = screenWidth * 0.75;
    }

    return Theme(
      data: Theme.of(context),
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [upperHalf(context), lowerHalf(context)],
            ),
          ),
        ),
      ),
    );
  }

  Widget upperHalf(BuildContext context) {
    return SizedBox(
      height: screenHeight / 4.5,
      width: resWidth * 0.9,
      child: Image.asset(
        'assets/images/moneyminder3.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget lowerHalf(BuildContext context) {
    return Container(
        width: resWidth,
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
            child: Column(
          children: [
            Card(
                elevation: 10,
                child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(25, 10, 20, 25),
                    child: Theme(
                      data: Theme.of(context),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              "Login",
                              style: TextStyle(
                                fontSize: resWidth * 0.05,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                                textInputAction: TextInputAction.next,
                                validator: (val) => val!.isEmpty ||
                                        !val.contains("@") ||
                                        !val.contains(".")
                                    ? "Please enter a valid email"
                                    : null,
                                focusNode: focus,
                                onFieldSubmitted: (v) {
                                  FocusScope.of(context).requestFocus(focus1);
                                },
                                controller: _emailditingController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                    //labelStyle: TextStyle(),
                                    labelText: 'Email',
                                    icon: Icon(
                                      Icons.email,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 2.0),
                                    ))),
                            TextFormField(
                              textInputAction: TextInputAction.done,
                              validator: (val) => val!.isEmpty
                                  ? "Please enter a password"
                                  : null,
                              focusNode: focus1,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context).requestFocus(focus2);
                              },
                              controller: _passEditingController,
                              decoration: InputDecoration(
                                  //labelStyle: const TextStyle(),
                                  labelText: 'Password',
                                  icon: const Icon(
                                    Icons.lock,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0),
                                  )),
                              obscureText: _passwordVisible,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _isChecked,
                                        onChanged: (bool? value) {
                                          _onRememberMeChanged(value!);
                                        },
                                        activeColor: Colors
                                            .orange, // Change the color when the checkbox is selected
                                        checkColor: Colors.white,
                                      ),
                                      const Text('Remember me',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ],
                                  ),
                                  Flexible(
                                    flex: 5,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: Size(screenWidth / 3, 50),
                                        foregroundColor: Colors
                                            .white, // Fixed foreground color to white
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                      ),
                                      onPressed: _loginUser,
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ]),
                          ],
                        ),
                      ),
                    ))),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Register new account? ",
                    style: TextStyle(fontSize: 16.0)),
                GestureDetector(
                  onTap: () => {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const RegisterScreen()))
                  },
                  child: const Text(
                    " Click here",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Forgot password? ",
                    style: TextStyle(fontSize: 16.0)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    " Click here",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        )));
  }

  void _loginUser() {
    FocusScope.of(context).requestFocus(FocusNode());
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please fill in the login credentials",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      _isChecked = false;
      return;
    }
    /*ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text(
          "Please wait..",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        title: const Text(
          "Login user",
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
    progressDialog.show();*/
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const CustomProgressDialog(
          title: "Login..",
        );
      },
    );

    String _email = _emailditingController.text;
    String _pass = _passEditingController.text;
    http.post(Uri.parse("${MyConfig.server}/mypfm/php/login_user.php"),
        body: {"email": _email, "password": _pass}).then((response) {
      print(response.body);
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        User user = User.fromJson(jsondata['data']);
        Fluttertoast.showToast(
            msg: "Login Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        Navigator.of(context).pop(); // Dismiss the dialog
        final currencyProvider =
            Provider.of<CurrencyProvider>(context, listen: false);
        currencyProvider.setUserId(user.id);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(
                user: user,
                currencyProvider:
                    Provider.of<CurrencyProvider>(context, listen: false)),
          ),
          (route) => false, // This condition removes all routes from the stack
        );
      } else {
        Fluttertoast.showToast(
            msg: "Login Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
      }
      Navigator.of(context).pop(); // Dismiss the dialog
    });
  }

  void saveremovepref(bool value) async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please fill in the login credentials",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      _isChecked = false;
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());
    FocusScope.of(context).unfocus();
    String email = _emailditingController.text;
    String password = _passEditingController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      //save preference
      await prefs.setString('email', email);
      await prefs.setString('pass', password);
      Fluttertoast.showToast(
          msg: "Login Credentials Saved",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    } else {
      //delete preference
      await prefs.setString('email', '');
      await prefs.setString('pass', '');
      /*setState(() {
        _emailditingController.text = '';
        _passEditingController.text = '';
        _isChecked = false;
      });*/
      Fluttertoast.showToast(
          msg: "Login Credentials Removed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    }
  }

  void _onRememberMeChanged(bool newValue) => setState(() {
        _isChecked = newValue;
        if (_isChecked) {
          saveremovepref(true);
        } else {
          saveremovepref(false);
        }
      });

  Future<void> loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = (prefs.getString('email')) ?? '';
    String password = (prefs.getString('pass')) ?? '';
    if (email.length > 1 && password.length > 1) {
      setState(() {
        _emailditingController.text = email;
        _passEditingController.text = password;
        _isChecked = true;
      });
    }
  }
}
