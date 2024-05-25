import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:month_year_picker/month_year_picker.dart';
//import 'package:flutter_month_picker/flutter_month_picker.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/model/expense.dart';
import 'package:mypfm/model/income.dart';
import 'package:mypfm/model/user.dart';
import 'package:mypfm/view/addrecordscreen.dart';
import 'package:mypfm/view/recorddetailsscreen.dart';
import 'package:mypfm/view/registerscreen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'currency_provider.dart';

class TabRecordScreen extends StatefulWidget {
  final User user;
  const TabRecordScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TabRecordScreen> createState() => _TabRecordScreenState();
}

class _TabRecordScreenState extends State<TabRecordScreen> {
  List expenselist = [];
  List incomelist = [];
  List allRecords = [];
  String titlecenter = "Loading data...";
  late DateTime _selectedMonth;
  int numExpense = 0;
  int numIncome = 0;
  //String currency = "RM";
  var logger = Logger();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    /*_loadExpense();
    _loadIncome();*/
    _loadRecords(_selectedMonth.year, _selectedMonth.month);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the selected currency from the provider
    Currency? selectedCurrencyObject =
        Provider.of<CurrencyProvider>(context).selectedCurrency;

// Get the currency code
    String selectedCurrency = selectedCurrencyObject?.code ?? 'MYR';

    double totalIncome = calculateTotalIncome(incomelist);
    double totalExpense = calculateTotalExpense(expenselist);
    double convertedTotalIncome = _convertAmount(totalIncome, selectedCurrency);
    double convertedTotalExpense = _convertAmount(totalExpense, selectedCurrency);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Colors.orangeAccent,
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
            // Total income and expenses
            Container(
              color: Color.fromARGB(255, 255, 245, 230),
              padding: const EdgeInsets.all(2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        'Income',
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        '$selectedCurrency ${convertedTotalIncome.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Expense',
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        '$selectedCurrency ${convertedTotalExpense.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Record list
            Expanded(
              child: expenselist.isEmpty && incomelist.isEmpty
                  ? Center(
                      child: Text(titlecenter,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)))
                  : ListView.builder(
                      itemCount: _getNumberOfDaysInMonth(
                          _selectedMonth.year,
                          _selectedMonth
                              .month), // Replace with actual number of days in a month
                      itemBuilder: (context, index) {
                        return _buildDailyRecord(index);
                      },
                      padding: const EdgeInsets.only(bottom: 80),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _handleAddRecordBtn();
        },
        tooltip: "Add Record",
        //backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Adjust the value as needed
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Method to build daily record
  Widget _buildDailyRecord(int index) {
    // Get the selected currency from the provider
    Currency? selectedCurrencyObject =
        Provider.of<CurrencyProvider>(context).selectedCurrency;

// Get the currency code
    String selectedCurrency = selectedCurrencyObject?.code ?? 'MYR';

    // Combine income and expense records into a single list
    allRecords = [...expenselist, ...incomelist];

    // Group records by date
    var groupedRecords = <DateTime, List>{};
    for (var record in allRecords) {
      var date =
          DateTime.parse(record['expense_date'] ?? record['income_date']);
      if (!groupedRecords.containsKey(date)) {
        groupedRecords[date] = [];
      }
      groupedRecords[date]!.add(record);
    }

    // Sort records within each date group
    groupedRecords.forEach((date, records) {
      records.sort((a, b) {
        var aCreationDate = DateTime.parse(
            a['expense_creationdate'] ?? a['income_creationdate']);
        var bCreationDate = DateTime.parse(
            b['expense_creationdate'] ?? b['income_creationdate']);

        // Sort by creation date if the dates are the same
        if (aCreationDate != bCreationDate) {
          return bCreationDate.compareTo(aCreationDate);
        } else {
          // Sort by date if creation dates are the same
          return date.compareTo(date);
        }
      });
    });

    // Get sorted dates
    var sortedDates = groupedRecords.keys.toList();
    sortedDates.sort((a, b) => b.compareTo(a));

    // Ensure that index is within the bounds of sortedDates list
    if (index < 0 || index >= sortedDates.length) {
      return const SizedBox(); // Return an empty widget if index is out of bounds
    }

    // Get records for the selected index date
    var recordsForDay = groupedRecords[sortedDates[index]] ?? [];

    // Calculate total income and total expense
    double dailyIncome = 0;
    double dailyExpense = 0;
    double convertedDailyIncome = 0;
    double convertedDailyExpense = 0;
    for (var record in recordsForDay) {
      if (record.containsKey('income_amount')) {
        dailyIncome += double.parse(record['income_amount']);
        convertedDailyIncome = _convertAmount(dailyIncome, selectedCurrency);
      } else if (record.containsKey('expense_amount')) {
        dailyExpense += double.parse(record['expense_amount']);
        convertedDailyExpense = _convertAmount(dailyExpense, selectedCurrency);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Color.fromARGB(255, 255, 227, 186),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${sortedDates[index].day}/${sortedDates[index].month}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 180,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$selectedCurrency ${convertedDailyIncome.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.blue),
                      ),
                      /*const SizedBox(
                        width: 30,
                      ),*/
                      Text(
                        '$selectedCurrency ${convertedDailyExpense.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        // Use ListView.builder to iterate over recordsForDay
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: recordsForDay.length,
          itemBuilder: (context, i) {
            var record = recordsForDay[i];
            // Convert the amount to the selected currency
            double amount = double.parse(record.containsKey('expense_amount')
                ? record['expense_amount']
                : record['income_amount']);
            double convertedAmount = _convertAmount(amount, selectedCurrency);

            return GestureDetector(
              onTap: () => _recordDetails(recordsForDay[i]),
              onLongPress: () => _deleteRecordDialog(recordsForDay[i]),
              child: Container(
                color: Color.fromARGB(255, 255, 245, 230),
                child: Column(
                  children: [
                    ListTile(
                      visualDensity: VisualDensity(vertical: -4),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 1, horizontal: 16),
                      leading: Icon(
                        Icons.attach_money,
                        color: record.containsKey('expense_amount')
                            ? Colors.red
                            : Colors.blue,
                      ),
                      title: Text(
                        record.containsKey('expense_note')
                            ? record['expense_note']
                            : record['income_note'],
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        record.containsKey('expense_category')
                            ? record['expense_category']
                            : record['income_category'],
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      trailing: Text(
                        '$selectedCurrency ${convertedAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: record.containsKey('expense_amount')
                              ? Colors.red
                              : Colors.blue,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _refresh() async {
    _loadRecords(_selectedMonth.year, _selectedMonth.month);
  }

  // Method to show month picker
  /*Future<void> _showMonthPicker() async {
    final pickedMonth = await showMonthPicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDate: _selectedMonth,
      //locale: const Locale("en"), // Set the locale if needed
    );
    if (pickedMonth != null && pickedMonth != _selectedMonth) {
      setState(() {
        _selectedMonth = pickedMonth;
        // Reload records for the selected month
        _loadRecords(_selectedMonth.year, _selectedMonth.month);
      });
    }
  }*/

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
          // Reload records for the selected month
          _loadRecords(_selectedMonth.year, _selectedMonth.month);
        });
      }
    }
    return null;
  }

  void _goToPreviousMonth() {
    if (!_isDisposed) {
      setState(() {
        _selectedMonth =
            DateTime(_selectedMonth.year, _selectedMonth.month - 1);
        _loadRecords(_selectedMonth.year,
            _selectedMonth.month); // Reload records for the new selected month
      });
    }
  }

  void _goToNextMonth() {
    if (!_isDisposed) {
      setState(() {
        _selectedMonth =
            DateTime(_selectedMonth.year, _selectedMonth.month + 1);
        _loadRecords(_selectedMonth.year,
            _selectedMonth.month); // Reload records for the new selected month
      });
    }
  }

  // Method to get number of days in a month
  int _getNumberOfDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  double calculateTotalIncome(List incomeList) {
    double totalIncome = 0;
    for (var record in incomeList) {
      totalIncome += double.parse(record['income_amount']);
    }
    return totalIncome;
  }

  double calculateTotalExpense(List expenseList) {
    double totalExpense = 0;
    for (var record in expenseList) {
      totalExpense += double.parse(record['expense_amount']);
    }
    return totalExpense;
  }

  Future<void> _handleAddRecordBtn() async {
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
            content: const Text('You need to register first to add records.'),
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
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddRecordScreen(user: widget.user),
        ),
      );
      _loadRecords(_selectedMonth.year, _selectedMonth.month);
    }
  }

  void _loadRecords(int year, int month) {
    if (_isDisposed) {
      return; // Check if the widget is disposed
    }
    if (widget.user.id == "unregistered") {
      setState(() {
        titlecenter = "No Records Found";
      });
      return;
    }
    // Load both income and expense records for the selected month
    _loadExpense(year, month);
    _loadIncome(year, month);
  }

  void _loadExpense(int year, int month) {
    if (_isDisposed) {
      return; // Check if the widget is disposed
    }
    /*if (widget.user.id == "unregistered") {
      setState(() {
        titlecenter = "Unregistered User";
      });
      return;
    }*/
    print(month);
    http.post(Uri.parse("${MyConfig.server}/mypfm/php/loadExpense.php"), body: {
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
            expenselist = extractdata;
            numExpense = expenselist.length;
          });
        }
      } else if (response.statusCode == 200 && jsondata['status'] == 'failed') {
        // Handle case when no records are found
        if (!_isDisposed) {
          setState(() {
            titlecenter = "No Records Found";
            expenselist = []; // Clear existing data
            numExpense = 0;
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
    });
  }

  void _loadIncome(int year, int month) {
    if (_isDisposed) {
      return; // Check if the widget is disposed
    }
    /*if (widget.user.id == "unregistered") {
      setState(() {
        titlecenter = "Unregistered User";
      });
      return;
    }*/
    http.post(Uri.parse("${MyConfig.server}/mypfm/php/loadIncome.php"), body: {
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
            incomelist = extractdata;
            numIncome = incomelist.length;
          });
        }
      } else if (response.statusCode == 200 && jsondata['status'] == 'failed') {
        // Handle case when no records are found
        if (!_isDisposed) {
          setState(() {
            titlecenter = "No Records Found";
            incomelist = []; // Clear existing data
            numIncome = 0;
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
    });
  }

  _recordDetails(var record) async {
    // Check if it's an expense or income record
    if (record.containsKey('expense_id')) {
      print(record['expense_id']);
      // It's an expense record
      Expense expense = Expense(
        expenseId: record['expense_id'],
        expenseDate: record['expense_date'],
        expenseAmount: record['expense_amount'],
        expenseCategory: record['expense_category'],
        expenseAccount: record['expense_account'],
        expenseNote: record['expense_note'],
        expenseDesc: record['expense_desc'],
        expenseCreationDate: record['expense_creationdate'],
        userId: record['user_id'],
      );
      // Navigate to the record details screen with the expense object
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              RecordDetailsScreen(record: expense, user: widget.user),
        ),
      );
      // Refresh the data after returning from the details screen
      _refresh();
    } else if (record.containsKey('income_id')) {
      print(record['income_id']);
      // It's an income record
      Income income = Income(
        incomeId: record['income_id'],
        incomeDate: record['income_date'],
        incomeAmount: record['income_amount'],
        incomeCategory: record['income_category'],
        incomeAccount: record['income_account'],
        incomeNote: record['income_note'],
        incomeDesc: record['income_desc'],
        incomeCreationDate: record['income_creationdate'],
        userId: record['user_id'],
      );
      // Navigate to the record details screen with the income object
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              RecordDetailsScreen(record: income, user: widget.user),
        ),
      );
      // Refresh the data after returning from the details screen
      _refresh();
    }
  }

  void _deleteRecordDialog(var record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Delete record",
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
                _deleteRecord(record);
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

  _deleteRecord(var record) async {
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Delete record in progress.."),
        title: const Text("Deleting..."));
    progressDialog.show();
    if (record.containsKey('expense_id')) {
      print(record['expense_id']);
      await http.post(
          Uri.parse("${MyConfig.server}/mypfm/php/deleteExpense.php"),
          body: {
            "expense_id": record['expense_id'],
          }).then((response) {
        progressDialog.dismiss();
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          print(record['expense_id']); //debug
          if (data['status'] == 'success') {
            Fluttertoast.showToast(
                msg: "Delete Record Success.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                fontSize: 14.0);
            return;
          } else {
            print(response.body);
            Fluttertoast.showToast(
                msg: "Delete Record Failed",
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
    } else if (record.containsKey('income_id')) {
      print(record['income_id']);
      await http.post(
          Uri.parse("${MyConfig.server}/mypfm/php/deleteIncome.php"),
          body: {
            "income_id": record['income_id'],
          }).then((response) {
        progressDialog.dismiss();
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          print(record['income_id']); //debug
          if (data['status'] == 'success') {
            Fluttertoast.showToast(
                msg: "Delete Record Success.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                fontSize: 14.0);
            return;
          } else {
            print(response.body);
            Fluttertoast.showToast(
                msg: "Delete Record Failed",
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
    _refresh();
  }

  // Method to convert amount to selected currency
  double _convertAmount(double amount, String selectedCurrency) {
    // Get the CurrencyProvider instance
    CurrencyProvider currencyProvider =
        Provider.of<CurrencyProvider>(context, listen: false);

    // Get the selected currency
    Currency? selectedCurrencyObject = currencyProvider.selectedCurrency;

    // Check if selected currency is null or if the provided currency code doesn't match
    if (selectedCurrencyObject == null ||
        selectedCurrencyObject.code != selectedCurrency) {
      // Return the original amount if selected currency is null or doesn't match
      return amount;
    }

    // Convert the amount using the selected currency rate
    return amount * selectedCurrencyObject.rate;
  }
}
