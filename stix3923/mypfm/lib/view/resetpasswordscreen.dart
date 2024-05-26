import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:mypfm/model/config.dart';
import 'package:ndialog/ndialog.dart';
import 'package:http/http.dart' as http;
//import 'package:uni_links/uni_links.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String token;
  const ResetPasswordScreen(
      {Key? key, required this.token, required this.email})
      : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  var logger = Logger();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = true;
  final focus = FocusNode();
  final TextEditingController _newPassEditingController =
      TextEditingController();
  final TextEditingController _newPass2EditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    //_handleIncomingLinks();
    focus.attach(context);
  }

  /*void _handleIncomingLinks() async {
    // Check if the app was opened by a deep link
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      _handleLink(initialLink);
    }

    // Attach a listener to the link stream only if the app was not opened by a deep link
    if (initialLink == null) {
      linkStream.listen((String? link) {
        if (link != null) {
          _handleLink(link);
        }
      }, onError: (err) {
        // Handle exception by warning the user their action did not succeed
        Fluttertoast.showToast(
          msg: "Failed to handle incoming link: $err",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      });
    }
  }

  void _handleLink(String link) {
    final uri = Uri.parse(link);
    if (uri.queryParameters.containsKey('token') &&
        uri.queryParameters.containsKey('email')) {
      final token = uri.queryParameters['token']!;
      final email = uri.queryParameters['email']!;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(token: token, email: email),
        ),
      );
    }
  }*/

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Change Password',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  textInputAction: TextInputAction.next,
                  validator: (val) => validatePassword(val.toString()),
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(focus);
                  },
                  controller: _newPassEditingController,
                  decoration: InputDecoration(
                      //labelStyle: const TextStyle(color: Colors.orange),
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
                const SizedBox(height: 16.0),
                TextFormField(
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
                  onPressed: _resetPassDialog,
                  style: ElevatedButton.styleFrom(
                      foregroundColor:
                          Colors.white, // Fixed foreground color to white
                      backgroundColor: Theme.of(context)
                          .primaryColor), // Set onPressed to null when valid
                  child: const Text('Reset',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
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

  void _resetPassDialog() {
    if (!_formKey.currentState!.validate()) {
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
            style: TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
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
                style: TextStyle(),
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
    String _pass = _newPassEditingController.text;
    FocusScope.of(context).unfocus();
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Reset password in progress.."),
        title: const Text("Updating..."));
    progressDialog.show();

    http.post(Uri.parse("${MyConfig.server}/mypfm/php/resetPassword.php"),
        body: {"email": widget.email, "password": _pass}).then((response) {
      progressDialog.dismiss();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        if (data['status'] == 'success') {
          Fluttertoast.showToast(
              msg: "Password reset success.",
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
}
