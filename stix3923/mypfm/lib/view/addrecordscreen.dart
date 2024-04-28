import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/model/user.dart';
import 'package:intl/intl.dart';
import 'package:ndialog/ndialog.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AddRecordScreen extends StatefulWidget {
  final User user;
  const AddRecordScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  var logger = Logger();
  String selectedType = "Expense"; // Initial selected type
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  final focus = FocusNode();
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();
  final focus4 = FocusNode();
  final focus5 = FocusNode();

  final List<String> categories = [
    "Food",
    "Rent",
    "Bills",
    "Transportation",
    "Entertainment",
    "Other"
  ];

  final List<String> accounts = ["Cash", "Bank Account", "E-wallet", "Other"];

  @override
  void dispose() {
    _focusScopeNode.dispose();
    _dateController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _accountController.dispose();
    _noteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Add Record",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: FocusScope(
        node: _focusScopeNode,
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Row for Income/Expense buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedType = "Income";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedType == "Income"
                              ? Colors.green
                              : Colors.grey[
                                  200], // Set button color based on selection
                        ),
                        child: Text(
                          "Income",
                          style: TextStyle(
                              color: selectedType == "Income"
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedType = "Expense";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedType == "Expense"
                              ? Colors.red
                              : Colors.grey[
                                  200], // Set button color based on selection
                        ),
                        child: Text(
                          "Expense",
                          style: TextStyle(
                              color: selectedType == "Expense"
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0), // Add spacing

                  // Form fields
                  TextFormField(
                    controller: _dateController,
                    readOnly: true, // Make date field read-only
                    decoration: const InputDecoration(
                      labelText: "Date",
                      icon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? initialDate;
                      if (_dateController.text.isNotEmpty) {
                        try {
                          // Parse the date string from _dateController
                          initialDate = DateFormat('dd/MM/yyyy')
                              .parse(_dateController.text);
                        } on FormatException catch (e) {
                          print("Error parsing date: $e");
                          // Handle parsing error (optional)
                        }
                      }

                      // Handle date selection using a date picker package (not included here)
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: initialDate ?? DateTime.now(),
                        firstDate: DateTime(2023, 1, 1),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        final DateFormat formatter = DateFormat(
                            'dd/MM/yyyy'); // Adjust format as needed (e.g., 'yyyy-MM-dd')
                        final formattedDate = formatter.format(pickedDate);
                        setState(() {
                          _dateController.text = formattedDate.toString();
                          //focus.requestFocus();
                        });
                        _focusScopeNode.requestFocus(focus);
                        print(_dateController.text);
                      }
                    },
                    validator: (value) =>
                        value!.isEmpty ? "Please select a date" : null,
                    /*onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(focus);
                    },*/
                  ),
                  const SizedBox(height: 10.0),

                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      icon: Icon(Icons.attach_money),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter amount" : null,
                    focusNode: focus,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (v) {
                      _focusScopeNode.requestFocus(focus1);
                    },
                  ),
                  const SizedBox(height: 10.0),

                  GestureDetector(
                    onTap: () {
                      // Open bottom sheet when tapped
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => CategorySelectionBottomSheet(
                          categories: categories,
                          onCategorySelected: (selectedCategory) {
                            setState(() {
                              _categoryController.text = selectedCategory;
                            });
                            _focusScopeNode.requestFocus(focus2);
                          },
                        ),
                      );
                    },
                    child: AbsorbPointer(
                      // Disable text field interaction to prevent keyboard from showing
                      absorbing: true,
                      child: TextFormField(
                        readOnly: true,
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: "Category",
                          icon: Icon(Icons.category),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Please select category" : null,
                        focusNode: focus1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  TextFormField(
                    readOnly: true,
                    controller:
                        _accountController, // Make account field read-only
                    decoration: const InputDecoration(
                      labelText: "Account",
                      icon: Icon(
                          Icons.account_balance), // Optional icon for the field
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please select account" : null,
                    focusNode: focus2,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => AccountSelectionBottomSheet(
                          accounts: accounts, // Pass your accounts list
                          onAccountSelected: (selectedAccount) {
                            setState(() {
                              _accountController.text = selectedAccount;
                            });
                            _focusScopeNode.requestFocus(focus3);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10.0),

                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: "Note (Optional)",
                      icon: Icon(Icons.note_alt_outlined),
                    ),
                    focusNode: focus3,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (v) {
                      _focusScopeNode.requestFocus(focus4);
                    },
                  ),
                  const SizedBox(height: 10.0),

                  /*TextFormField(
                    controller: _descriptionController,
                    maxLines: 3, // Allow multiple lines for description
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      labelText: "Description (Optional)",
                      icon: Icon(Icons.description_outlined),
                    ),
                    onEditingComplete: () {
                      FocusScope.of(context)
                          .unfocus(); // Close keyboard after editing
                    },
                  ),*/
                  TextFormField(
                      //textInputAction: TextInputAction.next,
                      focusNode: focus4,
                      onFieldSubmitted: (v) {
                        _focusScopeNode.requestFocus(focus5);
                      },
                      maxLines: 4,
                      controller: _descriptionController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          alignLabelWithHint: true,
                          labelStyle: TextStyle(),
                          icon: Icon(
                            Icons.description_outlined,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                          ))),
                  const SizedBox(height: 20.0),

                  // Row for Save and Cancel buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _addRecordDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.white, // Set your desired background color
                          foregroundColor:
                              Colors.orange, // Set your desired text color
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Clear Form"),
                              content: const Text(
                                  "Are you sure?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    _formKey.currentState!.reset();
                                    _clearAllControllers();
                                    Navigator.pop(
                                        context); // Close screen after clearing
                                  },
                                  child: const Text("Yes"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context), // Dismiss dialog
                                  child: const Text("No"),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.white, // Set your desired background color
                          foregroundColor:
                              Colors.orange, // Set your desired text color
                        ),
                        child: const Text(
                          "Clear",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _clearAllControllers() {
    setState(() {
      _dateController.text = "";
      _amountController.clear();
      _categoryController.clear();
      _accountController.clear();
      _noteController.clear();
      _descriptionController.clear();
    });
  }

  void _addRecordDialog() {
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
            "Add record",
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
                _addRecord();
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

  void _addRecord() {
    FocusScope.of(context).requestFocus(FocusNode());
    String _date = _dateController.text;
    String _amount = _amountController.text;
    String _category = _categoryController.text;
    String _account = _accountController.text;
    String? _note = _noteController.text.isEmpty ? null : _noteController.text;
    String? _desc = _descriptionController.text.isEmpty
        ? null
        : _descriptionController.text;
    print(widget.user.id);
    print("Check data: $_date $_amount $_category $_account $_note $_desc");
    FocusScope.of(context).unfocus();
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Add record in progress.."),
        title: const Text("Adding..."));
    progressDialog.show();

    http.post(Uri.parse("${MyConfig.server}/mypfm/php/addExpense.php"), body: {
      "user_id": widget.user.id,
      "expense_date": _date,
      "expense_amount": _amount,
      "expense_category": _category,
      "expense_account": _account,
      "expense_note": _note ?? "", // Send an empty string if note is null
      "expense_desc": _desc ?? "" // Send an empty string if address is null
    }).then((response) {
      progressDialog.dismiss();
      print(widget.user.id);
      print(_account);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(widget.user.id); //debug
        print(data); //debug
        // Check if all fields were successfully updated
        if (data['status'] == 'success') {
          Fluttertoast.showToast(
              msg: "Add Record Success.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          _formKey.currentState?.reset();
          _clearAllControllers();
          return;
        } else {
          print(response.body);
          Fluttertoast.showToast(
              msg: data['error'] ?? "Add Record Failed",
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
          msg: "An error occurred: $error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    });
  }
}

class CategorySelectionBottomSheet extends StatefulWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;

  const CategorySelectionBottomSheet({
    Key? key,
    required this.categories,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategorySelectionBottomSheet> createState() =>
      _CategorySelectionBottomSheetState();
}

class _CategorySelectionBottomSheetState
    extends State<CategorySelectionBottomSheet> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _focusScopeNode,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Category",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Handle "Edit" button press (navigate to edit screen or implement logic here)
                          _handleEditCategoryBtn();
                          print("Edit button pressed!"); // Placeholder for now
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3, // Adjust columns as needed
                  childAspectRatio: 1.8,
                  physics:
                      const ClampingScrollPhysics(), // Adjust cell aspect ratio for better look
                  children: widget.categories
                      .map((category) => _CategoryItem(
                            category: category,
                            onPressed: () => {
                              widget.onCategorySelected(category),
                              Navigator.pop(context),
                            },
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                      onPressed: () {
                        // Handle "Add" button press (navigate to add category screen or implement logic here)
                        _handleAddCategoryBtn(); // Placeholder for now
                      },
                      tooltip: "Add Category",
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(Icons.add)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  void _handleAddCategoryBtn() {}

  void _handleEditCategoryBtn() {}
}

class _CategoryItem extends StatelessWidget {
  final String category;
  final Function() onPressed;

  const _CategoryItem({
    Key? key,
    required this.category,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(5.0), // Adjust padding as needed
        minimumSize: const Size(100.0, 30.0), // Set minimum size for each cell
      ),
      child: Text(
        category,
        maxLines: 2, // Allow wrapping for longer text
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.bold), // Truncate if text overflows
      ),
    );
  }
}

class AccountSelectionBottomSheet extends StatefulWidget {
  final List<String> accounts; // List of predefined accounts
  final Function(String) onAccountSelected;

  const AccountSelectionBottomSheet({
    Key? key,
    required this.accounts,
    required this.onAccountSelected,
  }) : super(key: key);

  @override
  State<AccountSelectionBottomSheet> createState() =>
      _AccountSelectionBottomSheetState();
}

class _AccountSelectionBottomSheetState
    extends State<AccountSelectionBottomSheet> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _focusScopeNode,
      child: Container(
        color: Colors.white, // Set background color
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add some padding
          child: Column(
            mainAxisSize: MainAxisSize.min, // Set minimum height
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Account",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Handle "Edit" button press (navigate to edit screen or implement logic here)
                          _handleEditAccountBtn();
                          print("Edit button pressed!"); // Placeholder for now
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () =>
                            Navigator.pop(context), // Close the bottom sheet
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(), // Add a divider line
              Expanded(
                // Allows the content to fill the remaining space
                child: GridView.count(
                  crossAxisCount: 3,
                  // 3 accounts per row
                  childAspectRatio: 1.8,
                  physics: const ClampingScrollPhysics(),
                  children: widget.accounts
                      .map((account) => _AccountItem(
                            account: account,
                            onPressed: () {
                              widget.onAccountSelected(account);
                              Navigator.pop(context); // Close after selection
                            },
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 10.0), // Add a little spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                      onPressed: () {
                        // Handle "Add" button press (navigate to add category screen or implement logic here)
                        _handleAddAccountBtn(); // Placeholder for now
                      },
                      tooltip: "Add Account",
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(Icons.add)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  void _handleEditAccountBtn() {}

  void _handleAddAccountBtn() {}
}

class _AccountItem extends StatelessWidget {
  final String account;
  final Function() onPressed;

  const _AccountItem({
    Key? key,
    required this.account,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(5.0), // Adjust padding as needed
        minimumSize: const Size(100.0, 30.0), // Set minimum size for each cell
      ),
      child: Text(
        account,
        maxLines: 2, // Allow wrapping for longer text
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.bold), // Truncate if text overflows
      ),
    );
  }
}
