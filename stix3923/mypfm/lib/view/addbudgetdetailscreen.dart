import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/model/user.dart';
//import 'package:ndialog/ndialog.dart';
import 'package:mypfm/view/customprogressdialog.dart';
import 'currency_provider.dart';

class AddBudgetDetailScreen extends StatefulWidget {
  final User user;
  final DateTime selectedMonth;
  final String selectedCategory;
  final CurrencyProvider currencyProvider;
  const AddBudgetDetailScreen(
      {Key? key,
      required this.user,
      required this.selectedMonth,
      required this.selectedCategory,
      required this.currencyProvider})
      : super(key: key);

  @override
  State<AddBudgetDetailScreen> createState() => _AddBudgetDetailScreenState();
}

class _AddBudgetDetailScreenState extends State<AddBudgetDetailScreen> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedCategory,
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
              ElevatedButton(
                onPressed: _saveBudget,
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(
                      255, 255, 115, 0), // Fixed foreground color to white
                  backgroundColor: const Color.fromARGB(
                      255, 255, 255, 255), // Set your desired text color
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please enter valid information.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }

    String url = "${MyConfig.server}/mypfm/php/addBudget.php";
    double convertedAmount =
        _convertAmountSend(double.parse(_amountController.text));
    String _amount = convertedAmount.toString();
    print(widget.selectedMonth.toString());

    /*ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Add budget in progress..", style: TextStyle(fontWeight: FontWeight.bold),),
        title: const Text("Adding...", style: TextStyle(fontWeight: FontWeight.bold),));
    progressDialog.show();*/
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const CustomProgressDialog(
          title: "Adding...",
        );
      },
    );

    await http.post(Uri.parse(url), body: {
      "user_id": widget.user.id,
      "amount": _amount,
      "category": widget.selectedCategory,
      "year": widget.selectedMonth.year.toString(),
      "month": widget.selectedMonth.month.toString(),
    }).then((response) {
      Navigator.of(context).pop(); // Dismiss the dialog
      print(widget.user.id);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(widget.user.id); //debug
        print(data); //debug
        // Check if all fields were successfully updated
        if (data['status'] == 'success') {
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: "Add Budget Success.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
        } else {
          print(response.body);
          Fluttertoast.showToast(
              msg: data['error'] ?? "Add Budget Failed",
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

  // Method to convert amount to selected currency
  double _convertAmountSend(double amount) {
    // Convert the amount using the selected currency rate
    return widget.currencyProvider.convertAmountSend(amount);
  }
}
