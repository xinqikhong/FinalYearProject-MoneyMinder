import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/model/user.dart';
import 'package:ndialog/ndialog.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

class ChangePasswordScreen extends StatefulWidget {
  final User user;
  const ChangePasswordScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  var logger = Logger();
  final _formKey = GlobalKey<FormState>();
  /*String _currentPassword = "";
  String _newPassword = "";
  String _reEnterPassword = "";*/
  bool _passwordVisible = true;
  bool _isCurrentPasswordValid = false;
  final focus = FocusNode();
  final TextEditingController _curPassEditingController =
      TextEditingController();
  final TextEditingController _newPassEditingController =
      TextEditingController();
  final TextEditingController _newPass2EditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    focus.attach(context);
  }

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  enabled: !_isCurrentPasswordValid,
                  textInputAction: TextInputAction.next,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                  controller: _curPassEditingController,
                  decoration: InputDecoration(
                      labelStyle: const TextStyle(),
                      labelText: 'Current Password',
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
                  onPressed: _isCurrentPasswordValid ? null : _checkPass,
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                        Colors.white, // Fixed foreground color to white
                    backgroundColor: _isCurrentPasswordValid
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                  ), // Set onPressed to null when valid
                  child: const Text('Continue'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  enabled: _isCurrentPasswordValid,
                  textInputAction: TextInputAction.next,
                  validator: (val) => validatePassword(val.toString()),
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(focus);
                  },
                  controller: _newPassEditingController,
                  decoration: InputDecoration(
                      labelStyle: const TextStyle(),
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
                const SizedBox(height: 16.0),
                TextFormField(
                  enabled: _isCurrentPasswordValid,
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
                      labelStyle: const TextStyle(),
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
                  onPressed: _isCurrentPasswordValid ? _changePassDialog : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                        Colors.white, // Fixed foreground color to white
                    backgroundColor: _isCurrentPasswordValid
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ), // Set onPressed to null when valid
                  child: const Text('Save'),
                ),
                //Suggested by Bard
                /*TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                  onSaved: (newValue) => _currentPassword = newValue!,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  enabled:
                      _isCurrentPasswordValid, // Enable only if current password is valid
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a new password';
                    }
                    return null;
                  },
                  onSaved: (newValue) => _newPassword = newValue!,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  enabled:
                      _isCurrentPasswordValid, // Enable only if current password is valid
                  decoration: const InputDecoration(
                    labelText: 'Re-Enter Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please re-enter the new password';
                    }
                    if (value != _newPassword) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onSaved: (newValue) => _reEnterPassword = newValue!,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isCurrentPasswordValid
                      ? _handleSave
                      : null, // Disable if not valid
                  child: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                        _isCurrentPasswordValid ? Colors.white : Colors.grey,
                    backgroundColor: _isCurrentPasswordValid
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),*/
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

  void _checkPass() {
    String _curPass = _curPassEditingController.text;
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Check password in progress.."),
        title: const Text("Checking..."));
    progressDialog.show();

    http.post(Uri.parse("${MyConfig.server}/mypfm/php/checkPassword.php"),
        body: {
          "user_id": widget.user.id,
          "password": _curPass
        }).then((response) {
      progressDialog.dismiss();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        if (data['status'] == 'success') {
          Fluttertoast.showToast(
              msg: "Password is correct.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          setState(() {
            _isCurrentPasswordValid = true;
          });
        } else {
          Fluttertoast.showToast(
              msg: data['message'] ?? "Incorrect password.",
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

  void _changePassDialog() {
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
            "Change password?",
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
                _changePass();
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

  void _changePass() {
    FocusScope.of(context).requestFocus(FocusNode());
    String _pass = _newPassEditingController.text;
    FocusScope.of(context).unfocus();
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Change password in progress.."),
        title: const Text("Updating..."));
    progressDialog.show();

    http.post(Uri.parse("${MyConfig.server}/mypfm/php/changePassword.php"),
        body: {"user_id": widget.user.id, "password": _pass}).then((response) {
      progressDialog.dismiss();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
        if (data['status'] == 'success') {
          Fluttertoast.showToast(
              msg: "Password update success.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          Navigator.pop(context);
        } else {
          Fluttertoast.showToast(
              msg: data['message'] ?? "Password update failed.",
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
