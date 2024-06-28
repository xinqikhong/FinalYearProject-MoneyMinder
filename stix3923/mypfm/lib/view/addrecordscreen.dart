import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/model/user.dart';
import 'package:intl/intl.dart';
import 'package:mypfm/view/accountlistscreen.dart';
import 'package:mypfm/view/categorylistscreen.dart';
//import 'package:ndialog/ndialog.dart';
import 'package:mypfm/view/customprogressdialog.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
//import 'package:provider/provider.dart';
import 'currency_provider.dart';

class AddRecordScreen extends StatefulWidget {
  final User user;
  final CurrencyProvider currencyProvider;
  const AddRecordScreen(
      {Key? key, required this.user, required this.currencyProvider})
      : super(key: key);

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

  /*final List<String> categoriesExpense = [
    "Food",
    "Rent",
    "Bills",
    "Transportation",
    "Entertainment",
    "Other"
  ];

  final List<String> categoriesIncome = [
    "Salary",
    "Wages",
    "Interest",
    "Rental",
    "Gifts",
    "Awards",
    "Other"
  ];

  final List<String> accounts = ["Cash", "Bank Account", "E-wallet", "Other"];*/

  List<String> inCat = [];
  List<String> exCat = [];
  List<String> accounts = [];

  @override
  void initState() {
    super.initState();
    fetchCat();
    fetchAccount();
  }

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
              //color: Color.fromARGB(255, 255, 115, 0)
            )),
      ),
      body: Container(
  color: Theme.of(context).brightness == Brightness.dark
      ? Colors.black
      : Colors.white,
  child: FocusScope(
    node: _focusScopeNode,
    child: SingleChildScrollView(
      child: Column(
        children: [
          Divider(
            height: 0.5,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedType = "Income";
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: selectedType == "Income"
                              ? Color.fromARGB(255, 255, 115, 0)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Text(
                          'Income',
                          style: TextStyle(
                            fontSize: 18,
                            color: selectedType == "Income"
                                ? Color.fromARGB(255, 255, 115, 0)
                                : Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedType = "Expense";
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: selectedType == "Expense"
                              ? Color.fromARGB(255, 255, 115, 0)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Text(
                          'Expense',
                          style: TextStyle(
                            fontSize: 18,
                            color: selectedType == "Expense"
                                ? Color.fromARGB(255, 255, 115, 0)
                                : Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            margin: const EdgeInsets.only(
                left: 20.0, right: 20.0, bottom: 20.0, top: 10.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Date",
                      icon: Icon(Icons.calendar_today,
                          color: Theme.of(context).iconTheme.color),
                      labelStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1!.color),
                    ),
                    onTap: () async {
                      DateTime? initialDate;
                      if (_dateController.text.isNotEmpty) {
                        try {
                          initialDate = DateFormat('dd/MM/yyyy')
                              .parse(_dateController.text);
                        } on FormatException catch (e) {
                          print("Error parsing date: $e");
                        }
                      }
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: initialDate ?? DateTime.now(),
                        firstDate: DateTime(2023, 1, 1),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        final DateFormat formatter =
                            DateFormat('dd/MM/yyyy');
                        final formattedDate = formatter.format(pickedDate);
                        setState(() {
                          _dateController.text = formattedDate.toString();
                        });
                        _focusScopeNode.requestFocus(focus);
                        print(_dateController.text);
                      }
                    },
                    validator: (value) =>
                        value!.isEmpty ? "Please select a date" : null,
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Amount",
                      icon: Icon(Icons.attach_money,
                          color: Theme.of(context).iconTheme.color),
                      labelStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1!.color),
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
                      showModalBottomSheet(
                          context: context,
                          builder: (context) =>
                              CategorySelectionBottomSheet(
                                  categories: selectedType == "Expense"
                                      ? exCat
                                      : inCat,
                                  onCategorySelected: (selectedCategory) {
                                    setState(() {
                                      _categoryController.text =
                                          selectedCategory;
                                    });
                                    _focusScopeNode.requestFocus(focus2);
                                  },
                                  selectedType: selectedType,
                                  user: widget.user,
                                  fetchCat: fetchCat));
                    },
                    child: AbsorbPointer(
                      absorbing: true,
                      child: TextFormField(
                        readOnly: true,
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: "Category",
                          icon: Icon(Icons.category,
                              color: Theme.of(context).iconTheme.color),
                          labelStyle: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .color),
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
                    controller: _accountController,
                    decoration: InputDecoration(
                      labelText: "Account",
                      icon: Icon(Icons.account_balance,
                          color: Theme.of(context).iconTheme.color),
                      labelStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1!.color),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please select account" : null,
                    focusNode: focus2,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => AccountSelectionBottomSheet(
                            accounts: accounts,
                            onAccountSelected: (selectedAccount) {
                              setState(() {
                                _accountController.text = selectedAccount;
                              });
                              _focusScopeNode.requestFocus(focus3);
                            },
                            user: widget.user,
                            fetchAccount: fetchAccount),
                      );
                    },
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: "Note (Optional)",
                      icon: Icon(Icons.note_alt_outlined,
                          color: Theme.of(context).iconTheme.color),
                      labelStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1!.color),
                    ),
                    focusNode: focus3,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (v) {
                      _focusScopeNode.requestFocus(focus4);
                    },
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    focusNode: focus4,
                    onFieldSubmitted: (v) {
                      _focusScopeNode.requestFocus(focus5);
                    },
                    maxLines: 4,
                    controller: _descriptionController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      alignLabelWithHint: true,
                      icon: Icon(Icons.description_outlined,
                          color: Theme.of(context).iconTheme.color),
                      labelStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1!.color),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _addRecordDialog,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Color.fromARGB(255, 255, 115, 0),
                          backgroundColor: Theme.of(context).brightness ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                "Clear Form",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22),
                              ),
                              content: const Text(
                                "Are you sure?",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                              actions: [
                                Center(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _formKey.currentState!.reset();
                                          _clearAllControllers();
                                          Navigator.pop(context);
                                        },
                                        style: Theme.of(context)
                                            .textButtonTheme
                                            .style,
                                        child: const Text(
                                          "Yes",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        style: Theme.of(context)
                                            .textButtonTheme
                                            .style,
                                        child: const Text(
                                          "No",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Color.fromARGB(255, 255, 115, 0),
                          backgroundColor: Theme.of(context).brightness ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        child: const Text(
                          "Clear",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
                      _addRecord();
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

  void _addRecord() {
    FocusScope.of(context).requestFocus(FocusNode());
    String url = "";
    String _date = _dateController.text;
    double convertedAmount =
        _convertAmountSend(double.parse(_amountController.text));
    String _amount = convertedAmount.toString();
    String _category = _categoryController.text;
    String _account = _accountController.text;
    String? _note = _noteController.text.isEmpty ? null : _noteController.text;
    String? _desc = _descriptionController.text.isEmpty
        ? null
        : _descriptionController.text;
    print(widget.user.id);
    print("Check data: $_date $_amount $_category $_account $_note $_desc");
    FocusScope.of(context).unfocus();
    /*ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text(
          "Add record in progress..",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        title: const Text(
          "Adding...",
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
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
    if (selectedType == "Expense") {
      url = "${MyConfig.server}/mypfm/php/addExpense.php";
    } else {
      url = "${MyConfig.server}/mypfm/php/addIncome.php";
    }

    http.post(Uri.parse(url), body: {
      "user_id": widget.user.id,
      "date": _date,
      "amount": _amount,
      "category": _category,
      "account": _account,
      "note": _note ?? "", // Send an empty string if note is null
      "desc": _desc ?? "" // Send an empty string if address is null
    }).then((response) {
      Navigator.of(context).pop(); // Dismiss the dialog
      print(widget.user.id);
      print(_account);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(widget.user.id); //debug
        print(data); //debug
        // Check if all fields were successfully updated
        if (data['status'] == 'success') {
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: "Add Record Success.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
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
      Navigator.of(context).pop(); // Dismiss the dialog
      logger.e("An error occurred: $error");
      Fluttertoast.showToast(
          msg: "An error occurred: $error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    });
  }

  Future<void> fetchCat() async {
    try {
      // Fetch expense categories
      final exCatResponse = await http.post(
        Uri.parse("${MyConfig.server}/mypfm/php/getExCat.php"),
        body: {"user_id": widget.user.id},
      );
      if (exCatResponse.statusCode == 200) {
        final dynamic exCatData = jsonDecode(exCatResponse.body)['categories'];
        final List<String> exCatList =
            (exCatData as List).cast<String>(); // Cast to List<String>
        setState(() {
          exCat = exCatList;
        });
      }
      print(exCat);

      // Fetch income categories
      final inCatResponse = await http.post(
        Uri.parse("${MyConfig.server}/mypfm/php/getInCat.php"),
        body: {"user_id": widget.user.id},
      );
      if (inCatResponse.statusCode == 200) {
        final dynamic inCatData = jsonDecode(inCatResponse.body)['categories'];
        final List<String> inCatList =
            (inCatData as List).cast<String>(); // Cast to List<String>
        setState(() {
          inCat = inCatList;
        });
      }
      print(inCat);
    } catch (e) {
      logger.e("Error fetching categories: $e");
    }
  }

  Future<void> fetchAccount() async {
    try {
      // Fetch expense categories
      final accountResponse = await http.post(
        Uri.parse("${MyConfig.server}/mypfm/php/getAccount.php"),
        body: {"user_id": widget.user.id},
      );
      if (accountResponse.statusCode == 200) {
        final dynamic accData = jsonDecode(accountResponse.body)['account'];
        final List<String> accList =
            (accData as List).cast<String>(); // Cast to List<String>
        setState(() {
          accounts = accList;
        });
      }
      print(accounts);
    } catch (e) {
      logger.e("Error fetching account: $e");
    }
  }

  // Method to convert amount to selected currency
  double _convertAmountSend(double amount) {
    // Convert the amount using the selected currency rate
    return widget.currencyProvider.convertAmountSend(amount);
  }
}

class CategorySelectionBottomSheet extends StatefulWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;
  final String selectedType;
  final User user;
  final Function fetchCat;

  const CategorySelectionBottomSheet({
    Key? key,
    required this.categories,
    required this.onCategorySelected,
    required this.selectedType,
    required this.user,
    required this.fetchCat,
  }) : super(key: key);

  @override
  State<CategorySelectionBottomSheet> createState() =>
      _CategorySelectionBottomSheetState();
}

class _CategorySelectionBottomSheetState
    extends State<CategorySelectionBottomSheet> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    return FocusScope(
  node: _focusScopeNode,
  child: Container(
    color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16.0), // Add some padding
      child: Column(
        mainAxisSize: MainAxisSize.min, // Set minimum height
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Category",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyText1!.color,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _editCategoryScreen();
                      print("Edit button pressed!"); // Placeholder for now
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            // Allows the content to fill the remaining space
            child: GridView.count(
              crossAxisCount: 3, // Adjust columns as needed
              childAspectRatio: 1.8,
              physics: const ClampingScrollPhysics(), // Adjust cell aspect ratio for better look
              children: widget.categories
                  .map((category) => _CategoryItem(
                        category: category,
                        onPressed: () {
                          widget.onCategorySelected(category);
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
                  _addCategory(); // Placeholder for now
                },
                tooltip: "Add Category",
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.add),
              ),
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

  void _addCategory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newCategoryName = '';
        return AlertDialog(
          title: const Text(
            'Add Category',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          content: TextField(
            onChanged: (value) {
              newCategoryName = value;
            },
            decoration: const InputDecoration(hintText: 'Enter category name'),
          ),
          actions: <Widget>[
            /*TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),*/
            Center(
              child: TextButton(
                onPressed: () async {
                  // Validate if the category name is not empty
                  if (newCategoryName.isNotEmpty) {
                    // Validate if the category name is not already in the list
                    if (!widget.categories.contains(newCategoryName)) {
                      if (widget.selectedType == "Income") {
                        // Add to income categories list
                        setState(() {
                          widget.categories.add(newCategoryName);
                        });
                        // Add logic to add new category to the database
                        try {
                          final response = await http.post(
                            Uri.parse(
                                "${MyConfig.server}/mypfm/php/addInCat.php"),
                            body: {
                              "user_id": widget.user.id,
                              "category_name": newCategoryName,
                            },
                          );
                          if (response.statusCode == 200) {
                            // Category added successfully
                            var data = jsonDecode(response.body);
                            print(data);
                            if (data['status'] == 'success') {
                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                  msg: "Add Category Success.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  fontSize: 14.0);
                            } else {
                              // Handle error
                              Fluttertoast.showToast(
                                  msg: "Add Category Failed",
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
                          logger.e("Error adding category: $e");
                          // Handle error
                          Fluttertoast.showToast(
                              msg: "An error occurred: $e",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              fontSize: 14.0);
                        }
                      } else if (widget.selectedType == "Expense") {
                        // Add to expense categories list
                        setState(() {
                          widget.categories.add(newCategoryName);
                        });
                        // Add logic to add new category to the database
                        try {
                          final response = await http.post(
                            Uri.parse(
                                "${MyConfig.server}/mypfm/php/addExCat.php"),
                            body: {
                              "user_id": widget.user.id,
                              "category_name": newCategoryName,
                            },
                          );
                          if (response.statusCode == 200) {
                            // Category added successfully
                            var data = jsonDecode(response.body);
                            print(data);
                            if (data['status'] == 'success') {
                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                  msg: "Add Category Success.",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  fontSize: 14.0);
                            } else {
                              // Handle error
                              Fluttertoast.showToast(
                                  msg: "Add Category Failed",
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
                          logger.e("Error adding category: $e");
                          // Handle error
                          Fluttertoast.showToast(
                              msg: "An error occurred: $e",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              fontSize: 14.0);
                        }
                      }
                    } else {
                      // Show error message if category name already exists
                      Fluttertoast.showToast(
                          msg: "Category name already exists.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          fontSize: 14.0);
                    }
                  } else {
                    // Show error message if category name is empty
                    Fluttertoast.showToast(
                        msg: "Please enter a category name.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        fontSize: 14.0);
                  }
                },
                child: const Text('Save',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                style: Theme.of(context).textButtonTheme.style,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editCategoryScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CategoryListScreen(
              user: widget.user,
              selectedType: widget.selectedType,
              categories: widget.categories)),
    );
    //Navigator.pop(context);
    fetchCat();
    widget.fetchCat();
    //fetchCat();
  }

  Future<void> fetchCat() async {
    String url;
    List<String> catList = [];
    try {
      if (widget.selectedType == "Expense") {
        url = "${MyConfig.server}/mypfm/php/getExCat.php";
      } else {
        url = "${MyConfig.server}/mypfm/php/getInCat.php";
      }
      // Fetch expense categories

      final catResponse = await http.post(
        Uri.parse(url),
        body: {"user_id": widget.user.id},
      );
      if (catResponse.statusCode == 200) {
        final dynamic catData = jsonDecode(catResponse.body)['categories'];
        catList = (catData as List).cast<String>(); // Cast to List<String>
        setState(() {
          widget.categories.setAll(0, catList);
        });
      }
      print("921: $catList");
    } catch (e) {
      logger.e("Error fetching categories: $e");
    }
  }
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
  final User user;
  final Function fetchAccount;

  const AccountSelectionBottomSheet({
    Key? key,
    required this.accounts,
    required this.onAccountSelected,
    required this.user,
    required this.fetchAccount,
  }) : super(key: key);

  @override
  State<AccountSelectionBottomSheet> createState() =>
      _AccountSelectionBottomSheetState();
}

class _AccountSelectionBottomSheetState
    extends State<AccountSelectionBottomSheet> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    return FocusScope(
  node: _focusScopeNode,
  child: Container(
    color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16.0), // Add some padding
      child: Column(
        mainAxisSize: MainAxisSize.min, // Set minimum height
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Account",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyText1!.color,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _editAccScreen();
                      print("Edit button pressed!"); // Placeholder for now
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context), // Close the bottom sheet
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(
            color: Theme.of(context).dividerColor,
          ),
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
                  _addAcc(); // Placeholder for now
                },
                tooltip: "Add Account",
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.add),
              ),
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

  void _addAcc() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newAccountName = '';
        return AlertDialog(
          title: const Text(
            'Add Account',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          content: TextField(
            onChanged: (value) {
              newAccountName = value;
            },
            decoration: const InputDecoration(hintText: 'Enter account name'),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                style: Theme.of(context).textButtonTheme.style,
                onPressed: () async {
                  // Validate if the account name is not empty
                  if (newAccountName.isNotEmpty) {
                    // Validate if the account name is not already in the list
                    if (!widget.accounts.contains(newAccountName)) {
                      // Add to account list
                      setState(() {
                        widget.accounts.add(newAccountName);
                      });
                      // Add logic to add new account to the database
                      try {
                        final response = await http.post(
                          Uri.parse(
                              "${MyConfig.server}/mypfm/php/addAccount.php"),
                          body: {
                            "user_id": widget.user.id,
                            "account_name": newAccountName,
                          },
                        );
                        if (response.statusCode == 200) {
                          // account added successfully
                          var data = jsonDecode(response.body);
                          print(data);
                          if (data['status'] == 'success') {
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                                msg: "Add Account Success.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                fontSize: 14.0);
                          } else {
                            // Handle error
                            Fluttertoast.showToast(
                                msg: "Add Account Failed",
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
                        logger.e("Error adding account: $e");
                        // Handle error
                        Fluttertoast.showToast(
                            msg: "An error occurred: $e",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            fontSize: 14.0);
                      }
                    } else {
                      // Show error message if account name already exists
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
                child: const Text('Save',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ),
            ),
            /*TextButton(
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // Fixed foreground color to white
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).primaryColor,
                  )),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),*/
          ],
        );
      },
    );
  }

  Future<void> _editAccScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              AccountListScreen(user: widget.user, accounts: widget.accounts)),
    );
    //Navigator.pop(context);
    fetchAccount();
    widget.fetchAccount();
  }

  Future<void> fetchAccount() async {
    String url = "${MyConfig.server}/mypfm/php/getAccount.php";
    List<String> accList = [];
    try {
      final accResponse = await http.post(
        Uri.parse(url),
        body: {"user_id": widget.user.id},
      );
      if (accResponse.statusCode == 200) {
        final dynamic accData = jsonDecode(accResponse.body)['account'];
        accList = (accData as List).cast<String>(); // Cast to List<String>
        setState(() {
          widget.accounts.setAll(0, accList);
        });
      }
      print(accList);
    } catch (e) {
      logger.e("Error fetching account: $e");
    }
  }
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
