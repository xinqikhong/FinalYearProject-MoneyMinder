import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/model/expense.dart';
import 'package:mypfm/model/income.dart';
import 'package:mypfm/model/user.dart';
import 'package:mypfm/view/addrecordscreen.dart';
import 'package:mypfm/view/registerscreen.dart';
import 'package:http/http.dart' as http;

class TabRecordScreen extends StatefulWidget {
  final User user;
  const TabRecordScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TabRecordScreen> createState() => _TabRecordScreenState();
}

class _TabRecordScreenState extends State<TabRecordScreen> {
  List expenselist = [];
  //List<Expense>? expenseList;

  List incomelist = [];
  //List<Income>? incomeList;

  String titlecenter = "Loading data...";
  late DateTime _selectedMonth;
  int numExpense = 0;
  int numIncome = 0;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    /*_loadExpense();
    _loadIncome();*/
    _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: expenselist.isEmpty && incomelist.isEmpty
          ? Center(
              child: Text(titlecenter,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)))
          : Column(
              children: [
                // Pagination for months
                Center(
                  child: Container(
                    height: 40, // Adjust height as needed
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: _goToPreviousMonth,
                          icon: const Icon(Icons.arrow_back),
                        ),
                        TextButton(
                          onPressed: _showMonthPicker,
                          child: Text(
                            '${_selectedMonth.month}/${_selectedMonth.year}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ), // Display selected month
                        IconButton(
                          onPressed: _goToNextMonth,
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                // Total income and expenses
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Income: \$XXXX'),
                      Text('Total Expense: \$XXXX'),
                    ],
                  ),
                ),
                const Divider(),
                // Record list
                Expanded(
                  child: ListView.builder(
                    itemCount: _getNumberOfDaysInMonth(
                        _selectedMonth.year,
                        _selectedMonth
                            .month), // Replace with actual number of days in a month
                    itemBuilder: (context, index) {
                      return _buildDailyRecord(index);
                    },
                    padding: EdgeInsets.only(bottom: 80),
                  ),
                ),
              ],
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
    // Combine income and expense records into a single list
    List allRecords = [...expenselist, ...incomelist];

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

    // Get sorted dates
    var sortedDates = groupedRecords.keys.toList();
    sortedDates.sort((a, b) => b.compareTo(a));

    // Ensure that index is within the bounds of sortedDates list
    if (index < 0 || index >= sortedDates.length) {
      return SizedBox(); // Return an empty widget if index is out of bounds
    }

    // Get records for the selected index date
    var recordsForDay = groupedRecords[sortedDates[index]] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${sortedDates[index].day}/${sortedDates[index].month}/${sortedDates[index].year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        for (var record in recordsForDay)
          ListTile(
            leading: Icon(Icons.attach_money,
                color: record.containsKey('expense_amount')
                    ? Colors.red
                    : Colors.blue),
            title: Text(record.containsKey('expense_note')
                ? record['expense_note']
                : record['income_note']),
            subtitle: Text(record.containsKey('expense_category')
                ? record['expense_category']
                : record['income_category']),
            trailing: Text(
              '\$${record.containsKey('expense_amount') ? record['expense_amount'] : record['income_amount']}',
              style: TextStyle(
                  color: record.containsKey('expense_amount')
                      ? Colors.red
                      : Colors.blue),
            ),
          ),
      ],
    );
  }

  // Method to show month picker
  Future<void> _showMonthPicker() async {
    final pickedMonth = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (pickedMonth != null && pickedMonth != _selectedMonth) {
      setState(() {
        _selectedMonth = pickedMonth;
        // Reload records for the selected month
        //_loadExpense();
        //_loadIncome();
        _loadRecords();
      });
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _loadRecords(); // Reload records for the new selected month
    });
  }

  void _goToNextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _loadRecords(); // Reload records for the new selected month
    });
  }

  // Method to get number of days in a month
  int _getNumberOfDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  void _handleAddRecordBtn() {
    if (widget.user.id == "unregistered") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Register to Add Records',
              style: TextStyle(
                fontSize: 20, // Adjust the font size as needed
              ),
            ),
            content: const Text('You need to register first to add records.'),
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddRecordScreen(user: widget.user),
        ),
      );
    }
  }

  void _loadRecords() {
    if (widget.user.id == "unregistered") {
      setState(() {
        titlecenter = "Unregistered User";
      });
      return;
    }
    // Load both income and expense records for the selected month
    _loadExpense();
    _loadIncome();
  }

  void _loadExpense() {
    /*if (widget.user.id == "unregistered") {
      setState(() {
        titlecenter = "Unregistered User";
      });
      return;
    }*/
    http.post(Uri.parse("${MyConfig.server}/mypfm/php/loadExpense.php"),
        body: {'user_id': widget.user.id}).then((response) {
      var jsondata = jsonDecode(response.body);
      var extractdata = jsondata['data'];
      print(response.body);
      print(jsondata);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        setState(() {
          expenselist = extractdata;
          numExpense = expenselist.length;
        });
      } else {
        setState(() {
          titlecenter = "No Record Available";
        });
      }
    });
  }

  void _loadIncome() {
    /*if (widget.user.id == "unregistered") {
      setState(() {
        titlecenter = "Unregistered User";
      });
      return;
    }*/
    http.post(Uri.parse("${MyConfig.server}/mypfm/php/loadIncome.php"),
        body: {'user_id': widget.user.id}).then((response) {
      var jsondata = jsonDecode(response.body);
      var extractdata = jsondata['data'];
      print(response.body);
      print(jsondata);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        setState(() {
          incomelist = extractdata;
          numIncome = incomelist.length;
        });
      } else {
        setState(() {
          titlecenter = "No Record Available";
        });
      }
    });
  }
}
