import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/model/user.dart';
import 'package:http/http.dart' as http;
//import 'package:ndialog/ndialog.dart';
import 'package:mypfm/view/customprogressdialog.dart';
import 'currency_provider.dart';

class EditBudgetScreen extends StatefulWidget {
  final User user;
  final String budgetId;
  final String budgetAmount;
  final String budgetCategory;
  final CurrencyProvider currencyProvider;
  const EditBudgetScreen(
      {Key? key,
      required this.user,
      required this.budgetId,
      required this.budgetAmount,
      required this.budgetCategory,
      required this.currencyProvider})
      : super(key: key);

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    double _amount = double.parse(widget.budgetAmount);
    double _convertedAmountDisplay = _convertAmountDisplay(_amount);
    _amountController.text = _convertedAmountDisplay.toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budgetCategory,
            style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                //color: Color.fromARGB(255, 255, 115, 0)
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _editBudget,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromARGB(
                          255, 255, 115, 0), // Fixed foreground color to white
                      backgroundColor: Color.fromARGB(
                          255, 255, 255, 255), // Set your desired text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            18), // Adjust the border radius here
                      ),
                    ),
                    child: const Text(
                      "Save",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _deleteBudgetDialog,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromARGB(
                          255, 255, 115, 0), // Fixed foreground color to white
                      backgroundColor: Color.fromARGB(
                          255, 255, 255, 255), // Set your desired text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            18), // Adjust the border radius here
                      ),
                    ),
                    child: const Text(
                      "Delete",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ],
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
    double convertedAmount =
        _convertAmountSend(double.parse(_amountController.text));
    String _amount = convertedAmount.toString();

    /*ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Edit budget in progress..", style: TextStyle(fontWeight: FontWeight.bold),),
        title: const Text("Editing...", style: TextStyle(fontWeight: FontWeight.bold),));
    progressDialog.show();*/
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const CustomProgressDialog(
          title: "Updating...",
        );
      },
    );

    await http.post(Uri.parse(url), body: {
      "budget_id": widget.budgetId,
      "amount": _amount,
    }).then((response) {
      Navigator.of(context).pop(); // Dismiss the dialog
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
      Navigator.of(context).pop(); // Dismiss the dialog
      logger.e("An error occurred: $error");
      Fluttertoast.showToast(
          msg: "An error occurred.\nPlease try again later.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    });
  }

  void _deleteBudgetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Delete budget",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          content: const Text("Are you sure?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: const Text(
                      "Yes",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: Theme.of(context).textButtonTheme.style,
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteBudget();
                    },
                  ),
                  TextButton(
                    child: const Text(
                      "No",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: Theme.of(context).textButtonTheme.style,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  _deleteBudget() async {
    /*ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Delete budget in progress..", style: TextStyle(fontWeight: FontWeight.bold),),
        title: const Text("Deleting...", style: TextStyle(fontWeight: FontWeight.bold),));
    progressDialog.show();*/
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const CustomProgressDialog(
          title: "Deleting...",
          //message: "Delete record in progress..",
        );
      },
    );

    print(widget.budgetId);
    await http.post(Uri.parse("${MyConfig.server}/mypfm/php/deleteBudget.php"),
        body: {
          "budget_id": widget.budgetId,
        }).then((response) {
      Navigator.of(context).pop(); // Dismiss the dialog
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(widget.budgetId); //debug
        if (data['status'] == 'success') {
          Fluttertoast.showToast(
              msg: "Delete Budget Success.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          Navigator.pop(context);
          return;
        } else {
          print(response.body);
          Fluttertoast.showToast(
              msg: "Delete Budget Failed",
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
            msg: "Failed to connect to the server.\nPlease try again later.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
      }
    }).catchError((error) {
      Navigator.of(context).pop(); // Dismiss the dialog
      logger.e("An error occurred: $error");
      Fluttertoast.showToast(
          msg: "An error occurred:\nPlease try again later.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    });
  }

  // Method to convert amount to selected currency
  double _convertAmountDisplay(double amount) {
    // Convert the amount using the selected currency rate
    return widget.currencyProvider.convertAmountDisplay(amount);
  }

  // Method to convert amount to selected currency
  double _convertAmountSend(double amount) {
    // Convert the amount using the selected currency rate
    return widget.currencyProvider.convertAmountSend(amount);
  }
}
