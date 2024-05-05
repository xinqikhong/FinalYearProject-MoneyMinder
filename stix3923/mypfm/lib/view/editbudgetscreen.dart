import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:ndialog/ndialog.dart';

class EditBudgetScreen extends StatefulWidget {
  final User user;
  final String budgetId;
  final String budgetAmount;
  final String budgetCategory;
  const EditBudgetScreen({Key? key, required this.user, required this.budgetId, required this.budgetAmount, required this.budgetCategory}) : super(key: key);

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var logger = Logger();
  
  @override
  Widget build(BuildContext context) {
    _amountController.text = widget.budgetAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budgetCategory,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Budget Amount",
                  icon: Icon(Icons.attach_money),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter amount" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.white, // Set your desired background color
                  foregroundColor: Colors.orange, // Set your desired text color
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editBudget() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please enter valid information.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }

    String url = "${MyConfig.server}/mypfm/php/editBudget.php";
    String _amount = _amountController.text;

    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Edit budget in progress.."),
        title: const Text("Editing..."));
    progressDialog.show();

    await http.post(Uri.parse(url), body: {
      "budget_id": widget.budgetId,
      "amount": _amount,
    }).then((response) {
      progressDialog.dismiss();
      print(widget.budgetId);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(widget.budgetId); //debug
        print(data); //debug
        setState(() {
          _amountController.text = _amount;
        });
        // Check if all fields were successfully updated
        if (data['status'] == 'success') {
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: "Edit Budget Success.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
        } else {
          print(response.body);
          Fluttertoast.showToast(
              msg: "An error occured.\nPlease try again later.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          return;
        }
      } else {
        print(response.body);
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
          msg: "An error occurred.\nPlease try again later.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    });
  }
}