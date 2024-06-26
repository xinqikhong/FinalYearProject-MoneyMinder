import 'package:flutter/material.dart';

class CustomProgressDialog extends StatelessWidget {
  final String title;
  //final String message;

  const CustomProgressDialog({
    Key? key,
    required this.title,
    //required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15
            ),
          ),
          //const SizedBox(height: 10),
          //Text(message),
        ],
      ),
    );
  }
}