import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/model/user.dart';
import 'package:ndialog/ndialog.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  var logger = Logger();
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _addressEditingController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final focus = FocusNode();
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  //final focus3 = FocusNode();

  @override
  void initState() {
    super.initState();
    focus.attach(context);
    focus1.attach(context);
    focus2.attach(context);
    //focus3.attach(context);

    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 8,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(25, 10, 20, 25),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                            //readOnly: true,
                            //textInputAction: TextInputAction.next,
                            validator: (val) => _validateName(val!),
                            onFieldSubmitted: (v) {
                              FocusScope.of(context).requestFocus(focus);
                            },
                            autofocus: false,
                            controller: _nameEditingController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                labelText: 'Name*',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.person),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0),
                                ))),
                        TextFormField(
                            enabled: false,
                            //textInputAction: TextInputAction.next,
                            /*validator: (val) => _validateEmail(val!),
                            focusNode: focus,
                            onFieldSubmitted: (v) {
                              FocusScope.of(context).requestFocus(focus1);
                            },
                            autofocus: false,*/
                            controller: _emailEditingController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.grey),
                            decoration: const InputDecoration(
                                labelText: 'Email*',
                                labelStyle: TextStyle(color: Colors.grey),
                                icon: Icon(Icons.email),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0),
                                ))),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                            //readOnly: true,
                            //textInputAction: TextInputAction.next,
                            validator: (val) => _validatePhone(val!),
                            focusNode: focus,
                            onFieldSubmitted: (v) {
                              FocusScope.of(context).requestFocus(focus1);
                            },
                            autofocus: false,
                            controller: _phoneEditingController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                                labelText: 'Phone No.',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.phone_android_rounded),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0),
                                ))),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                            //readOnly: true,
                            textInputAction: TextInputAction.done,
                            validator: (val) => _validateAddress(val!),
                            focusNode: focus1,
                            onFieldSubmitted: (v) {
                              FocusScope.of(context).requestFocus(focus2);
                            },
                            autofocus: false,
                            controller: _addressEditingController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                labelText: 'Address',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.other_houses),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0),
                                ))),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              //style: ElevatedButton.styleFrom(
                              //fixedSize: Size(screenWidth / 3, 50)),
                              onPressed: _saveEditDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .white, // Set your desired background color
                                foregroundColor: Colors
                                    .orange, // Set your desired text color
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            /*ElevatedButton(
                              //style: ElevatedButton.styleFrom(
                              //fixedSize: Size(screenWidth / 3, 50)),
                              onPressed: _cancelEditDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .white, // Set your desired background color
                                foregroundColor: Colors
                                    .orange, // Set your desired text color
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),*/
                          ],
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _loadUserData() {
    // Assuming your user object has getters for name, email, phone, and address
    setState(() {
      _nameEditingController.text = widget.user.name!;
      _emailEditingController.text = widget.user.email!;

      // Check if phone is null before setting the text controller
      if (widget.user.phone != null) {
        _phoneEditingController.text = widget.user.phone!;
      } else {
        _phoneEditingController.text =
            ''; // Set an empty string if phone is null
      }

      // Check if address is null before setting the text controller
      if (widget.user.address != null) {
        _addressEditingController.text = widget.user.address!;
      } else {
        _addressEditingController.text =
            ''; // Set an empty string if address is null
      }
    });
  }

  @override
  void dispose() {
    focus.dispose();
    focus1.dispose();
    focus2.dispose();
    _nameEditingController.dispose();
    _emailEditingController.dispose();
    _phoneEditingController.dispose();
    _addressEditingController.dispose();
    super.dispose();
  }

  String? _validateName(String value) {
    if (value.isEmpty || value.length < 3) {
      return "Name must be longer than 3 characters";
    }
    return null; // No error
  }

  /*String? _validateEmail(String value) {
    if (value.isEmpty || !value.contains("@") || !value.contains(".")) {
      return "Enter a valid email (e.g. abc@example.com)";
    }
    return null; // No error
  }*/

  String? _validatePhone(String value) {
    if (value != null && value.isNotEmpty && value.length < 9) {
      return "Phone number should contains at least 9 digits";
    }
    return null; // No error (empty or valid)
  }

  String? _validateAddress(String value) {
    if (value != null && value.isNotEmpty && value.length < 5) {
      return "Address should contains at least 5 characters";
    }
    return null; // No error (empty or valid)
  }

  void _saveEditDialog() {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please enter valid information.",
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
            "Edit your profile",
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
                _editProfile();
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

  void _editProfile() {
    FocusScope.of(context).requestFocus(FocusNode());
    String _name = _nameEditingController.text;
    //String _email = _emailEditingController.text;
    String? _phone = _phoneEditingController.text.isEmpty
        ? null
        : _phoneEditingController.text;
    String? _address = _addressEditingController.text.isEmpty
        ? null
        : _addressEditingController.text;
    FocusScope.of(context).unfocus();
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Edit profile in progress.."),
        title: const Text("Editing..."));
    progressDialog.show();

    http.post(Uri.parse("${MyConfig.server}/mypfm/php/editProfile_user.php"),
        body: {
          "userid": widget.user.id,
          "name": _name,
          //"email": _email,
          "phone": _phone ?? "", // Send an empty string if phone is null
          "address": _address ?? "" // Send an empty string if address is null
        }).then((response) {
      progressDialog.dismiss();
      print(_phone);
      print(_address);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(widget.user.id); //debug
        print(data); //debug
        // Check if all fields were successfully updated
        bool allSuccess =
            data.values.every((value) => value['status'] == 'success');

        if (allSuccess) {
          Fluttertoast.showToast(
            msg: "Edit Profile Success.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0,
          );
          setState(() {
            widget.user.name = _nameEditingController.text;
            widget.user.phone = _phoneEditingController.text;
            widget.user.address = _addressEditingController.text;
            focus.attach(context);
            focus1.attach(context);
            focus2.attach(context);
          });
        } else {
          String errorMessage = data.values.firstWhere(
                  (value) => value['status'] != 'success',
                  orElse: () => {})['error'] ??
              "Edit Profile Failed";
          Fluttertoast.showToast(
              msg: errorMessage,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
        }
        print(widget.user.name);
        print(widget.user.phone);
        print(widget.user.address);
        _loadUserData();
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

  void _cancelEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Cancel edit",
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
                _formKey.currentState?.reset();
                _loadUserData();
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
}
