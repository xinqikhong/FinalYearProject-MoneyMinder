import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:ndialog/ndialog.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mypfm/model/config.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  var logger = Logger();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
        title: const Text('Forgot Password',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                  validator: (val) =>
                      val!.isEmpty || !val.contains("@") || !val.contains(".")
                          ? "Please enter a valid email"
                          : null,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      //labelStyle: TextStyle(),
                      labelText: 'Enter your registered email here',
                      icon: Icon(
                        Icons.mark_email_read,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2.0),
                      ))),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _checkEmail,
                style: ElevatedButton.styleFrom(
                  foregroundColor:
                      Colors.white, // Fixed foreground color to white
                  backgroundColor: Theme.of(context).primaryColor,
                ), // Set onPressed to null when valid
                child: const Text('Submit Request',
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
          msg: "Please fill in the login credentials",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    String _email = _emailController.text;
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Verify email in progress.."),
        title: const Text("Verifying..."));
    progressDialog.show();

    http.post(
        Uri.parse("${MyConfig.server}/mypfm/php/retrieveAndSendPassword.php"),
        body: {"email": _email}).then((response) {
      progressDialog.dismiss();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        if (data['status'] == 'success') {
          Fluttertoast.showToast(
              msg:
                  "Verification Success.\nKindly check your email for further instructions.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
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
}
