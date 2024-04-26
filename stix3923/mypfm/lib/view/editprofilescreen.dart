import 'package:flutter/material.dart';
import 'package:mypfm/model/user.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _addressEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final focus = FocusNode();
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
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
                                labelStyle: TextStyle(),
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
                            controller: _emailEditingController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.email),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0),
                                ))),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                            textInputAction: TextInputAction.next,
                            validator: (val) => val!.isEmpty || (val.length < 9)
                                ? "Phone number should have at least 9 digits"
                                : null,
                            focusNode: focus1,
                            onFieldSubmitted: (v) {
                              FocusScope.of(context).requestFocus(focus2);
                            },
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
                            textInputAction: TextInputAction.done,
                            validator: (val) => val!.isEmpty || (val.length < 9)
                                ? "Please enter a valid address"
                                : null,
                            focusNode: focus2,
                            onFieldSubmitted: (v) {
                              FocusScope.of(context).requestFocus(focus3);
                            },
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
                        ElevatedButton(
                          //style: ElevatedButton.styleFrom(
                          //fixedSize: Size(screenWidth / 3, 50)),
                          onPressed: _editProfileDialog,
                          child: const Text('Save'),
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

  void _editProfileDialog() {}
}
