import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/model/user.dart';

class AccountListScreen extends StatefulWidget {
  final User user;
  const AccountListScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  List<String> accounts = [];
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    fetchAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          String accountName = accounts[index];
          return Column(
            children: [
              ListTile(
                leading: const Icon(Icons.remove_circle_rounded,
                    color: Colors.red), // Red minus icon
                title: Text(accountName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Handle edit button press for the category
                        _editAccountName(accountName);
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
            ],
          );
        },
      ),
    );
  }

  Future<void> fetchAccount() async {
    try {
      // Fetch income categories
      final accResponse = await http.post(
        Uri.parse("${MyConfig.server}/mypfm/php/getAccount.php"),
        body: {"user_id": widget.user.id},
      );
      if (accResponse.statusCode == 200) {
        final dynamic accData = jsonDecode(accResponse.body)['account'];
        final List<String> accList =
            (accData as List).cast<String>(); // Cast to List<String>
        setState(() {
          accounts = accList;
        });
      }
      print(accounts);
    } catch (e) {
      logger.e("Error fetching accounts: $e");
    }
  }

  void _editAccountName(String accountName) {
    String url = "";
    final TextEditingController _accountController =
        TextEditingController(text: accountName);
    String newAccountName = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit'),
          content: TextField(
            controller: _accountController,
            decoration: InputDecoration(hintText: accountName),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Add to income categories list
                setState(() {
                  newAccountName = _accountController.text;
                });
                // Validate if the category name is not empty
                if (newAccountName.isNotEmpty) {
                  // Validate if the category name is not already in the list
                  if (!accounts.contains(newAccountName)) {
                      url = "${MyConfig.server}/mypfm/php/editAccount.php";
                    print(widget.user.id);
                    print("Check selected category: $accountName");
                    print("Check new category: $newAccountName");
                    // Add logic to add new category to the database
                    try {
                      final response = await http.post(
                        Uri.parse(url),
                        body: {
                          "user_id": widget.user.id,
                          "old_name": accountName,
                          "new_name": newAccountName
                        },
                      );
                      if (response.statusCode == 200) {
                        // Category added successfully
                        var data = jsonDecode(response.body);
                        print(data);
                        if (data['status'] == 'success') {
                          setState(() {
                            accounts.remove(
                                accountName); // Remove old category name
                            accounts
                                .add(newAccountName); // Add new category name
                          });
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                              msg: "Edit Account Success.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              fontSize: 14.0);
                        } else {
                          // Handle error
                          Fluttertoast.showToast(
                              msg: "Edit Account Failed",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              fontSize: 14.0);
                        }
                        return;
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
                        return;
                      }
                    } catch (e) {
                      logger.e("Error edit account: $e");
                      // Handle error
                      Fluttertoast.showToast(
                          msg: "An error occurred: $e",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          fontSize: 14.0);
                    }
                  } else {
                    // Show error message if category name already exists
                    Fluttertoast.showToast(
                        msg: "Account name already exists.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        fontSize: 14.0);
                  }
                } else {
                  // Show error message if category name is empty
                  Fluttertoast.showToast(
                      msg: "Please enter account name.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      fontSize: 14.0);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}