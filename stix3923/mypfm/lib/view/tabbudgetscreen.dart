import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:mypfm/model/user.dart';
import 'package:mypfm/model/config.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mypfm/view/addbudgetscreen.dart';
import 'package:mypfm/view/editbudgetscreen.dart';
import 'package:mypfm/view/registerscreen.dart';

class TabBudgetScreen extends StatefulWidget {
  final User user;
  const TabBudgetScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TabBudgetScreen> createState() => _TabBudgetScreenState();
}

class _TabBudgetScreenState extends State<TabBudgetScreen> {
  String titlecenter = "Loading data...";
  late DateTime _selectedMonth;
  List budgetlist = [];
  List expenselist = [];
  String currency = "RM";
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _loadBudget(_selectedMonth.year, _selectedMonth.month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadBudget(_selectedMonth.year, _selectedMonth.month);
        },
        child: Column(
          children: [
            // Pagination for months
            Center(
              child: Container(
                color: Color.fromARGB(255, 255, 245, 230),
                height: 40, // Adjust height as needed
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _goToPreviousMonth,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _showMonthPicker(context); // Call your function
                      },
                      child: Text(
                        DateFormat('MMM yyyy').format(_selectedMonth),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ), // Display selected month
                    IconButton(
                      onPressed: _goToNextMonth,
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 2),
            // Budget list
            Expanded(
              child: budgetlist.isEmpty
                  ? Center(
                      child: Text(titlecenter,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)))
                  /*child: Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child*/
                  : ListView.builder(
                      itemCount: budgetlist
                          .length, // Replace with actual category count
                      itemBuilder: (context, index) {
                        // Replace with budget widget
                        return _buildBudgetList(index);
                      },
                      padding: const EdgeInsets.only(bottom: 80),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _handleAddBudgetBtn();
        },
        tooltip: "Add Budget",
        //backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Adjust the value as needed
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  /*void _loadExCat() async {
    if (widget.user.id == "unregistered") {
      setState(() {
        titlecenter = "No Records Found";
      });
      return;
    }

    try {
      // Fetch expense categories
      final exCatResponse = await http.post(
        Uri.parse("${MyConfig.server}/mypfm/php/getExCat.php"),
        body: {"user_id": widget.user.id},
      );
      if (exCatResponse.statusCode == 200) {
        final dynamic exCatData = jsonDecode(exCatResponse.body)['categories'];
        final List<String> exCat =
            (exCatData as List).cast<String>(); // Cast to List<String>
        setState(() {
          excatlist = exCat;
        });
      }
      print(excatlist);
    } catch (e) {
      logger.e("Error fetching categories: $e");
    }
  }*/

  Future<void> _loadBudget(int year, int month) async {
    print("$month, $year");
    await http.post(Uri.parse("${MyConfig.server}/mypfm/php/loadBudget.php"),
        body: {
          'user_id': widget.user.id,
          'year': year.toString(),
          'month': month.toString()
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      var extractdata = jsondata['data'];
      print(extractdata);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        setState(() {
          budgetlist = extractdata;
        });
      } else if (response.statusCode == 200 && jsondata['status'] == 'failed') {
        // Handle case when no records are found
        setState(() {
          titlecenter = "No Records Found";
          budgetlist = []; // Clear existing data
        });
      } else {
        // Handle other error cases
        setState(() {
          titlecenter = "Error loading budget records";
        });
      }
    }).catchError((error) {
      logger.e("An error occurred when load budget: $error");
      Fluttertoast.showToast(
          msg: "An error occurred.\nPlease try again later.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    });
  }

  void _loadExpense(int year, int month, String selectedCategory) async {
    print("$month, $year, $selectedCategory");
    await http.post(
        Uri.parse("${MyConfig.server}/mypfm/php/loadExpenseForCat.php"),
        body: {
          'user_id': widget.user.id,
          'category': selectedCategory,
          'year': year.toString(),
          'month': month.toString()
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      var extractdata = jsondata['data'];
      print(extractdata);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        setState(() {
          expenselist = extractdata;
        });
      } else if (response.statusCode == 200 && jsondata['status'] == 'failed') {
        // Handle case when no records are found
        setState(() {
          //titlecenter = "No Records Found";
          expenselist = []; // Clear existing data
        });
      } else {
        // Handle other error cases
        Fluttertoast.showToast(
            msg: "An error occurred.\nPlease try again later.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
      }
    }).catchError((error) {
      logger.e("An error occurred when load budget: $error");
      Fluttertoast.showToast(
          msg: "An error occurred.\nPlease try again later.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    });
  }

  /*Future<void> _refresh() async {
    _loadExCat();
    _loadExpense(_selectedMonth.year, _selectedMonth.month, selectedCategory);
    _loadBudget(selectedCategory);
  }*/

  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _loadBudget(_selectedMonth.year,
          _selectedMonth.month); // Reload records for the new selected month
    });
  }

  Future<DateTime?> _showMonthPicker(BuildContext context) async {
    final pickedMonth = await showMonthYearPicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2010),
      lastDate: DateTime(2050),
    );
    if (pickedMonth != null && pickedMonth != _selectedMonth) {
      setState(() {
        _selectedMonth = pickedMonth;
        // Reload records for the selected month
        _loadBudget(_selectedMonth.year, _selectedMonth.month);
      });
    }
    return null;
  }

  void _goToNextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _loadBudget(_selectedMonth.year,
          _selectedMonth.month); // Reload records for the new selected month
    });
  }

  Widget _buildBudgetList(int index) {
    var budget = budgetlist[index];
    double budget_amount = double.parse(budget['budget_amount']);

    return GestureDetector(
      //onTap: () => _budgetDetails(budget),
      onLongPress: () => _deleteRecordDialog(budget),
      child: Container(
        color: Color.fromARGB(255, 255, 245, 230),
        child: Column(
          children: [
            ListTile(
              title: Text(
                budget['budget_category'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              //subtitle: Text('$currency ${budget_amount.toStringAsFixed(2)}'), // Replace with actual budget
              trailing: Text(
                '$currency ${budget_amount.toStringAsFixed(2)}', // Replace with actual expenses
                style: TextStyle(
                    color: Color.fromARGB(255, 3, 171, 68),
                    fontSize: 14,
                    fontWeight: FontWeight.bold // For expenses
                    ),
              ),
              onTap: () => _budgetDetails(budget),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddBudgetBtn() async {
    if (widget.user.id == "unregistered") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Register to Add Budget',
              style: TextStyle(
                fontSize: 20, // Adjust the font size as needed
              ),
            ),
            content: const Text('You need to register first to add budget.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text('Register'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddBudgetScreen(
              user: widget.user,
              //budgetlist: budgetlist,
              selectedMonth: _selectedMonth),
        ),
      );
      _loadBudget(_selectedMonth.year, _selectedMonth.month);
    }
  }

  _budgetDetails(var budget) async {
    print(budget['budget_id']);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => EditBudgetScreen(
            user: widget.user,
            budgetId: budget['budget_id'],
            budgetAmount: budget['budget_amount'],
            budgetCategory: budget['budget_category']),
      ),
    );
    _loadBudget(_selectedMonth.year, _selectedMonth.month);
  }

  _deleteRecordDialog(budget) {}
}
