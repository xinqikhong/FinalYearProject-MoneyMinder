import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/view/loginscreen.dart';
import 'package:http/http.dart' as http;
import 'package:ndialog/ndialog.dart';
import 'package:logger/logger.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Define a logger instance
  var logger = Logger();
  bool _isChecked = false;
  bool _passwordVisible = true;
  String eula = "";

  late double screenHeight, screenWidth, resWidth;
  final focus = FocusNode();
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();

  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _emailditingController = TextEditingController();
  final TextEditingController _passEditingController = TextEditingController();
  final TextEditingController _pass2EditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    focus.attach(context);
    focus1.attach(context);
    focus2.attach(context);
    focus3.attach(context);
  }

  @override
  void dispose() {
    focus.dispose();
    focus1.dispose();
    focus2.dispose();
    focus3.dispose();
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
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [upperHalf(context), lowerHalf(context)],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget upperHalf(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: SizedBox(
        height: screenHeight / 5.5,
        width: resWidth * 0.9,
        child: Image.asset(
          'assets/images/moneyminder3.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget lowerHalf(BuildContext context) {
    return Container(
      width: resWidth,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          Card(
            elevation: 10,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 10, 20, 25),
              color: Colors.white,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      "Register",
                      style: TextStyle(
                        fontSize: resWidth * 0.05,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    TextFormField(
                        textInputAction: TextInputAction.next,
                        validator: (val) => val!.isEmpty || (val.length < 3)
                            ? "Name must be longer than 3"
                            : null,
                        onFieldSubmitted: (v) {
                          FocusScope.of(context).requestFocus(focus);
                        },
                        controller: _nameEditingController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                            labelText: 'Name',
                            //labelStyle: TextStyle(),
                            icon: Icon(Icons.person),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 2.0),
                            ))),
                    TextFormField(
                        textInputAction: TextInputAction.next,
                        validator: (val) => val!.isEmpty ||
                                !val.contains("@") ||
                                !val.contains(".")
                            ? "Enter a valid email (e.g. abc@example.com)"
                            : null,
                        focusNode: focus,
                        onFieldSubmitted: (v) {
                          FocusScope.of(context).requestFocus(focus1);
                        },
                        controller: _emailditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            labelText: 'Email',
                            //labelStyle: TextStyle(),
                            icon: Icon(Icons.email),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 2.0),
                            ))),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      validator: (val) => validatePassword(val.toString()),
                      focusNode: focus1,
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).requestFocus(focus2);
                      },
                      controller: _passEditingController,
                      //keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                          //labelStyle: const TextStyle(),
                          labelText: 'Password',
                          icon: const Icon(Icons.lock),
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
                    TextFormField(
                      style: const TextStyle(),
                      textInputAction: TextInputAction.done,
                      validator: (val) {
                        validatePassword(val.toString());
                        if (val != _passEditingController.text) {
                          return "Password do not match";
                        } else {
                          return null;
                        }
                      },
                      focusNode: focus2,
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).requestFocus(focus3);
                      },
                      controller: _pass2EditingController,
                      //keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                          labelText: 'Re-enter Password',
                          //labelStyle: const TextStyle(),
                          icon: const Icon(Icons.lock),
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked = value!;
                            });
                          },
                          activeColor: Colors
                              .orange, // Change the color when the checkbox is selected
                          checkColor: Colors.white,
                        ),
                        Flexible(
                          child: GestureDetector(
                            onTap: _showEULA,
                            child: const Text('Agree with terms',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(screenWidth / 3.3, 50),
                            foregroundColor:
                                Colors.white, // Fixed foreground color to white
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          onPressed: _registerAccountDialog,
                          child: const Text(
                            'Register',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("Already Register? ",
                  style: TextStyle(
                    fontSize: 16.0,
                  )),
              GestureDetector(
                onTap: () => {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const LoginScreen()))
                },
                child: const Text(
                  "Login here",
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
        ],
      ),
    );
  }

  void _registerAccountDialog() {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please complete the registration form first",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }

    if (!_isChecked) {
      Fluttertoast.showToast(
          msg: "Please accept the terms and conditions",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Register new account?",
            style: TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _registerUser();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String? validatePassword(String value) {
    // String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regex = RegExp(pattern);
    if (value.isEmpty) {
      return 'Please enter password';
    } else {
      if (!regex.hasMatch(value)) {
        return 'Enter a valid password (e.g. Abc1234@)';
      } else {
        return null;
      }
    }
  }

  void _showEULA() {
    loadEula();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "EULA",
          ),
          content: SizedBox(
            height: screenHeight / 1.5,
            width: screenWidth,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                      child: RichText(
                    softWrap: true,
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
                        text: eula),
                  )),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Close",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  loadEula() async {
    eula = await rootBundle.loadString('assets/eula.txt');
  }

  void _registerUser() {
    FocusScope.of(context).requestFocus(FocusNode());
    String _name = _nameEditingController.text;
    String _email = _emailditingController.text;
    String _pass = _passEditingController.text;
    FocusScope.of(context).unfocus();
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Registration in progress.."),
        title: const Text("Registering..."));
    progressDialog.show();

    http.post(Uri.parse("${MyConfig.server}/mypfm/php/register_user.php"),
        body: {
          "name": _name,
          "email": _email,
          "password": _pass
        }).then((response) {
      progressDialog.dismiss();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        if (data['status'] == 'success') {
          Fluttertoast.showToast(
              msg: "Registration Success.\nCheck Email for Verification.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const LoginScreen()));
        } else {
          Fluttertoast.showToast(
              msg: data['error'] ?? "Registration Failed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
        }
      } else {
        print(
            "Failed to connect to the server. Status code: ${response.statusCode}");
        Fluttertoast.showToast(
            msg: "Failed to connect to the server",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
      }
    }).catchError((error) {
      progressDialog.dismiss();
      logger.e("An error occurred: $error");
      Fluttertoast.showToast(
          msg: "An error occurred: $error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    });
  }
}
