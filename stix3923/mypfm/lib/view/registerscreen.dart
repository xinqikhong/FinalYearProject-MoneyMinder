import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SingleChildScrollView(
      child: Card(
        elevation: 8,
        margin: EdgeInsets.all(8),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(),
                        icon: Icon(Icons.person),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ))),
                TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(),
                        icon: Icon(Icons.email),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ))),
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(),
                      icon: Icon(Icons.password),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2.0),
                      )),
                  obscureText: true,
                ),
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  decoration: const InputDecoration(
                      labelText: 'Re-enter Password',
                      labelStyle: TextStyle(),
                      icon: Icon(Icons.password),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2.0),
                      )),
                  obscureText: true,
                ),
                MaterialButton(
                  onPressed: null,
                  child: Text("Submit"),
                )
              ],
            ),
          ),
        ),
      ),
    )));
  }
}
