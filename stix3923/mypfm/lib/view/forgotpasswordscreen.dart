import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:ndialog/ndialog.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mypfm/model/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _newPassEditingController =
      TextEditingController();
  final TextEditingController _newPass2EditingController =
      TextEditingController();

  var logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _formKeyPass = GlobalKey<FormState>();
  bool _isEmailValid = false;
  bool _isTokenValid = false;
  bool _passwordVisible = true;
  final focus = FocusNode();

// Initialize SharedPreferences
  late SharedPreferences _prefs;
  // Variable to store the entered email temporarily
  late String _tempEmail;

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    // Read the stored email from SharedPreferences
    _tempEmail = _prefs.getString('tempEmail') ?? '';
    // Restore the entered email if available
    if (_tempEmail.isNotEmpty) {
      _emailController.text = _tempEmail;
      _isEmailValid = _prefs.getBool('isEmailValid') ?? false;
      setState(() {}); // Trigger a rebuild to update UI based on _isEmailValid
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Reset Password',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // First row containing email field and verify button
              Row(
                children: [
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        validator: (val) => val!.isEmpty ||
                                !val.contains("@") ||
                                !val.contains(".")
                            ? "Please enter a valid email"
                            : null,
                        controller: _emailController,
                        onChanged: (val) {
                          _tempEmail = val!;
                          // Save entered email to SharedPreferences
                          _prefs.setString('tempEmail', _tempEmail);
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Enter your registered email here',
                          icon: Icon(
                            Icons.mark_email_read,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: _checkEmail,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      'Verify',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Second row containing OTP field and verify button
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      enabled: _isEmailValid,
                      controller: _tokenController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Enter OTP here',
                        icon: Icon(Icons.key_rounded),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: _isEmailValid ? _checkToken : null,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: _isEmailValid
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    child: const Text(
                      'Verify',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Form(
                key: _formKeyPass,
                child: TextFormField(
                  enabled: _isTokenValid,
                  textInputAction: TextInputAction.next,
                  validator: (val) => validatePassword(val.toString()),
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(focus);
                  },
                  controller: _newPassEditingController,
                  decoration: InputDecoration(
                      //labelStyle: const TextStyle(color: Colors.orange),
                      labelText: 'New Password',
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
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                enabled: _isTokenValid,
                style: const TextStyle(),
                textInputAction: TextInputAction.done,
                validator: (val) {
                  validatePassword(val.toString());
                  if (val != _newPassEditingController.text) {
                    return "Password do not match";
                  } else {
                    return null;
                  }
                },
                focusNode: focus,
                controller: _newPass2EditingController,
                decoration: InputDecoration(
                    labelText: 'Re-enter Password',
                    //labelStyle: const TextStyle(color: Colors.orange),
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
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isTokenValid ? _resetPassDialog : null,
                style: ElevatedButton.styleFrom(
                  foregroundColor:
                      Colors.white, // Fixed foreground color to white
                  backgroundColor: _isTokenValid
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ), // Set onPressed to null when valid
                child: const Text('Reset Password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkEmail() {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please enter valid email",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    String _email = _emailController.text;
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Verify email in progress..", style: TextStyle(fontWeight: FontWeight.bold)),
        title: const Text("Verifying...", style: TextStyle(fontWeight: FontWeight.bold)));
    progressDialog.show();

    http.post(Uri.parse("${MyConfig.server}/mypfm/php/forgotPassword.php"),
        body: {"email": _email}).then((response) {
      progressDialog.dismiss();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        if (data['status'] == 'success') {
          Fluttertoast.showToast(
              msg: "Verification Success.\nKindly check your email for OTP.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          setState(() {
            _isEmailValid = true;
            // Save _isEmailValid to SharedPreferences
            _prefs.setBool('isEmailValid', true);
          });
          print(_isEmailValid);
        } else if (data['message'] == 'Inactive account') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                  'Invalid Email',
                  style: TextStyle(
                    fontSize: 20, // Adjust the font size as needed
                  ),
                ),
                content: const Text(
                    'Kindly contact us through email <moneyminder_admin@xqksoft.com> if you need any help.\nThank you.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.white), // Fixed foreground color to white
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).primaryColor,
                        )), // Dismiss dialog
                    child: const Text('Ok'),
                  ),
                ],
              );
            },
          );
        } else if (data['message'] == 'Unverified') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                  'Unverified Email',
                  style: TextStyle(
                    fontSize: 20, // Adjust the font size as needed
                  ),
                ),
                content: const Text(
                    'Kindly complete the verification first.\nYou can check your email for verification.\nThank you.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Colors.white), // Fixed foreground color to white
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).primaryColor,
                        )), // Dismiss dialog
                    child: const Text('Ok'),
                  ),
                ],
              );
            },
          );
        } else {
          Fluttertoast.showToast(
              msg: data['message'] ?? "Invalid email.",
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

  void _resetPassDialog() {
    if (!_formKeyPass.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please complete the form first",
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
            "Reset password?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure?", style: TextStyle(fontWeight: FontWeight.bold)),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // Fixed foreground color to white
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).primaryColor,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
                _resetPass();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // Fixed foreground color to white
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).primaryColor,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetPass() {
    FocusScope.of(context).requestFocus(FocusNode());
    String _email = _emailController.text;
    String _pass = _newPassEditingController.text;
    String _token = _tokenController.text;
    print('_email: $_email, _pass: $_pass, _token:$_token');
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Reset password in progress..", style: TextStyle(fontWeight: FontWeight.bold)),
        title: const Text("Updating...", style: TextStyle(fontWeight: FontWeight.bold)));
    progressDialog.show();

    http.post(Uri.parse("${MyConfig.server}/mypfm/php/resetPassword.php"),
        body: {
          "email": _email,
          "password": _pass,
          "token": _token
        }).then((response) {
      progressDialog.dismiss();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        if (data['status'] == 'success') {
          Fluttertoast.showToast(
              msg: "Password reset successfully.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          Navigator.pop(context);
        } else {
          Fluttertoast.showToast(
              msg: data['message'] ?? "Password reset failed.",
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

  void _checkToken() {
    String _token = _tokenController.text;
    String _email = _emailController.text;
    print('_token: $_token, _email: $_email');
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Check OTP in progress..", style: TextStyle(fontWeight: FontWeight.bold)),
        title: const Text("Checking...", style: TextStyle(fontWeight: FontWeight.bold)));
    progressDialog.show();

    http.post(Uri.parse("${MyConfig.server}/mypfm/php/checkToken.php"),
        body: {"email": _email, "token": _token}).then((response) {
      progressDialog.dismiss();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        if (data['status'] == 'success') {
          Fluttertoast.showToast(
              msg: "OTP is correct.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          setState(() {
            _isTokenValid = true;
          });
          print(_isTokenValid);
        } else {
          Fluttertoast.showToast(
              msg: data['message'] ?? "Incorrect OTP.",
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
