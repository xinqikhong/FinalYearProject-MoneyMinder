import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:mypfm/model/expense.dart';
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
import 'package:ndialog/ndialog.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'currency_provider.dart';

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
  //List expenselist = [];
  List<Expense> expenseList = [];
  List<Map<String, dynamic>> expenseProgressData = [];
  //String currency = "RM";
  var logger = Logger();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    budgetlist = [];
    expenseList = [];
    expenseProgressData = [];
    _loadData(_selectedMonth.year, _selectedMonth.month);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
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
                color: Color.fromARGB(255, 255, 227, 186),
                height: 40, // Adjust height as needed
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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

  void _loadData(int year, int month) async {
    if (_isDisposed) {
      return; // Check if the widget is disposed
    }
    if (widget.user.id == "unregistered") {
      if (!_isDisposed) {
        setState(() {
          titlecenter = "No Records Found";
        });
      }
      return;
    }

    await _loadBudget(year, month);
    await _loadExpense(year, month);
    _populateProgressData();

    if (!_isDisposed) {
      setState(() {
        // Refresh UI after loading data
      });
    } // Refresh UI after loading data
  }

  Future<void> _loadBudget(int year, int month) async {
    if (_isDisposed) {
      return; // Check if the widget is disposed
    }
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
        if (!_isDisposed) {
          setState(() {
            budgetlist = extractdata;
          });
        }
      } else if (response.statusCode == 200 && jsondata['status'] == 'failed') {
        // Handle case when no records are found
        if (!_isDisposed) {
          setState(() {
            titlecenter = "No Records Found";
            budgetlist = []; // Clear existing data
          });
        }
      } else {
        // Handle other error cases
        if (!_isDisposed) {
          setState(() {
            titlecenter = "Error loading budget records";
          });
        }
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

  Future<void> _loadExpense(int year, int month) async {
    if (_isDisposed) {
      return; // Check if the widget is disposed
    }
    print(month);
    await http.post(Uri.parse("${MyConfig.server}/mypfm/php/loadExpense.php"),
        body: {
          'user_id': widget.user.id,
          'year': year.toString(),
          'month': month.toString()
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      var extractdata = jsondata['data'];
      print(response.body);
      print(jsondata);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        if (!_isDisposed) {
          setState(() {
            expenseList = extractdata
                .map<Expense>((json) => Expense.fromJson(json))
                .toList();
          });
        }
      } else if (response.statusCode == 200 && jsondata['status'] == 'failed') {
        // Handle case when no records are found
        if (!_isDisposed) {
          setState(() {
            titlecenter = "No Records Found";
            expenseList = []; // Clear existing data
          });
        }
      } else {
        // Handle other error cases
        if (!_isDisposed) {
          setState(() {
            titlecenter = "Error loading expense records";
          });
        }
      }
    }).catchError((error) {
      logger.e("An error occurred when load expense: $error");
      Fluttertoast.showToast(
          msg: "An error occurred.\nPlease try again later.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    });
  }

  /*void _loadExpenseCat(int year, int month, String selectedCategory) async {
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
  }*/

  void _populateProgressData() {
    print('Start _populateProgressData()');
    expenseProgressData.clear();

    // Group expenses by category
    var groupedExpenses =
        groupBy(expenseList, (Expense expense) => expense.expenseCategory);

    // Calculate total expenses and add data to chart data
    groupedExpenses.forEach((category, expenseList) {
      double totalExpenseForCategory = expenseList.fold(
          0.0, (sum, expense) => sum + double.parse(expense.expenseAmount!));

      expenseProgressData.add({
        'category': category,
        'amount': totalExpenseForCategory
            .toStringAsFixed(2), // Format as string with 2 decimal places
        'percentage': 0.0, // Placeholder for percentage (calculated later)
      });
      print('$category  $totalExpenseForCategory');
    });

    _calculatePercentage();
  }

  void _calculatePercentage() {
    // Create a map to store calculated percentages for each category
    var categoryPercentages = {};

    // Find budget amounts for each category and store them in the map
    for (var budgetEntry in budgetlist) {
      String category = budgetEntry['budget_category'];
      double budgetAmount = double.parse(budgetEntry['budget_amount']);
      categoryPercentages[category] = budgetAmount;
    }

    // Calculate percentage for each category in expenseProgressData
    expenseProgressData.forEach((data) {
      String category = data['category'];
      double expenseAmount = double.parse(data['amount']);

      // Check if budget exists for the category
      if (categoryPercentages.containsKey(category)) {
        double budgetAmount = categoryPercentages[category];
        double percentage = (expenseAmount / budgetAmount) * 100;
        data['percentage'] = percentage.toStringAsFixed(2);
      } else {
        // Handle case where no budget is found for the category
        data['percentage'] =
            '0.00'; // Set percentage to zero (or display a placeholder)
      }
      print(data['category'] + ' ' + data['percentage']);
    });
  }

  /*Future<void> _refresh() async {
    _loadExCat();
    _loadExpense(_selectedMonth.year, _selectedMonth.month, selectedCategory);
    _loadBudget(selectedCategory);
  }*/

  void _goToPreviousMonth() {
    if (!_isDisposed) {
      setState(() {
        _selectedMonth =
            DateTime(_selectedMonth.year, _selectedMonth.month - 1);
        expenseProgressData = [];
        budgetlist = [];
        expenseList = [];
        _loadData(_selectedMonth.year,
            _selectedMonth.month); // Reload records for the new selected month
      });
    }
  }

  Future<DateTime?> _showMonthPicker(BuildContext context) async {
    final pickedMonth = await showMonthYearPicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2010),
      lastDate: DateTime(2050),
    );
    if (pickedMonth != null && pickedMonth != _selectedMonth) {
      if (!_isDisposed) {
        setState(() {
          _selectedMonth = pickedMonth;
          expenseProgressData = [];
          budgetlist = [];
          expenseList = [];
          _loadData(_selectedMonth.year, _selectedMonth.month);
        });
      }
    }
    return null;
  }

  void _goToNextMonth() {
    if (!_isDisposed) {
      setState(() {
        _selectedMonth =
            DateTime(_selectedMonth.year, _selectedMonth.month + 1);
        expenseProgressData = [];
        budgetlist = [];
        expenseList = [];
        _loadData(_selectedMonth.year,
            _selectedMonth.month); // Reload records for the new selected month
      });
    }
  }

  Widget _buildBudgetList(int index) {
    // Get the selected currency from the provider
    Currency? selectedCurrencyObject =
        Provider.of<CurrencyProvider>(context).selectedCurrency;

// Get the currency code
    String selectedCurrency = selectedCurrencyObject?.code ?? 'MYR';

    var budget = budgetlist[index];
    double budget_amount = double.parse(budget['budget_amount']);
    double convertedBudgetAmount =
        _convertAmount(budget_amount, selectedCurrency);
    String category = budget['budget_category'];
    double expenseAmount = 0.0;
    double convertedExpenseAmount = 0.0;
    double percentage = 0.0;
    for (var data in expenseProgressData) {
      if (data['category'] == category) {
        expenseAmount = double.parse(data['amount']);
        convertedExpenseAmount =
            _convertAmount(expenseAmount, selectedCurrency);
        percentage = double.parse(data['percentage']);
        break; // Exit loop once data for the category is found
      }
    }

    return GestureDetector(
      //onTap: () => _budgetDetails(budget),
      onLongPress: () => _deleteBudgetDialog(budget),
      child: Container(
        constraints: const BoxConstraints(maxWidth: double.infinity),
        color: Color.fromARGB(255, 255, 245, 230),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.attach_money,
                color: Color.fromARGB(255, 3, 171, 68),
              ),
              title: Text(
                category,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      '-$selectedCurrency ${convertedExpenseAmount.toStringAsFixed(2)}', // Budget amount
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 10), // Add spacing between budget and progress bar
                  Container(
                    constraints: const BoxConstraints(maxWidth: 150.0),
                    child: Stack(
                      // Set constraints explicitly
                      alignment: Alignment.center, // Optional: Center elements
                      clipBehavior:
                          Clip.none, // Optional: Allow overflowing content
                      children: [
                        Container(
                          width: 110.0, // Set desired width
                          height: 20.0,
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            borderRadius: BorderRadius.circular(5.0),
                            //minHeight: 15,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              percentage >= 100
                                  ? Colors.red
                                  : (percentage >= 80
                                      ? Colors.orange
                                      : Colors.green),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          top: 0,
                          child: Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              trailing: Container(
                //margin: const EdgeInsets.all(1.0),
                width: 100.0, // Set desired width
                height: 20.0,
                child: Text(
                  '$selectedCurrency ${convertedBudgetAmount.toStringAsFixed(2)}', // Expense amount
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Color.fromARGB(255, 3, 171, 68),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
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
              'Please Register',
              style: TextStyle(
                fontSize: 20, // Adjust the font size as needed
              ),
            ),
            content: const Text('You need to register first to add budget.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context), // Dismiss dialog
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to the RegisterScreen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text('Register'),
              ),
            ],
          );
        },
      );
    } else {
      print('handle add budget button');
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddBudgetScreen(
              user: widget.user,
              //budgetlist: budgetlist,
              selectedMonth: _selectedMonth),
        ),
      );
      _loadData(_selectedMonth.year, _selectedMonth.month);
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

  void _deleteBudgetDialog(var budget) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Delete budget",
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
                _deleteBudget(budget);
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

  _deleteBudget(var budget) async {
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Delete budget in progress.."),
        title: const Text("Deleting..."));
    progressDialog.show();

    print(budget['budget_id']);
    await http.post(Uri.parse("${MyConfig.server}/mypfm/php/deleteBudget.php"),
        body: {
          "budget_id": budget['budget_id'],
        }).then((response) {
      progressDialog.dismiss();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(budget['budget_id']); //debug
        if (data['status'] == 'success') {
          Fluttertoast.showToast(
              msg: "Delete Budget Success.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
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
      progressDialog.dismiss();
      logger.e("An error occurred: $error");
      Fluttertoast.showToast(
          msg: "An error occurred:\nPlease try again later.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    });
    _loadBudget(_selectedMonth.year, _selectedMonth.month);
  }

  // Method to convert amount to selected currency
  double _convertAmount(double amount, String selectedCurrency) {
    // Get the CurrencyProvider instance
    CurrencyProvider currencyProvider =
        Provider.of<CurrencyProvider>(context, listen: false);

    // Get the selected currency and base rate
    Currency? selectedCurrencyObject = currencyProvider.selectedCurrency;
    //double baseRate = currencyProvider.baseRate;

    // Check if selected currency is null or if the provided currency code doesn't match
    if (selectedCurrencyObject == null ||
        selectedCurrencyObject.code != selectedCurrency) {
      // Return the original amount if selected currency is null or doesn't match
      return amount;
    }

    // Convert the amount using the selected currency rate
    return currencyProvider.convertAmount(amount);
  }
}
