import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:math' as math;
import 'package:syncfusion_flutter_charts/charts.dart';

class TabStatsScreen extends StatefulWidget {
  final User user;
  const TabStatsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TabStatsScreen> createState() => _TabStatsScreenState();
}

class _TabStatsScreenState extends State<TabStatsScreen> {
  String titlecenter = "Loading data...";
  late DateTime _selectedMonth;
  String currency = "RM";
  var logger = Logger();
  bool _isIncomeSelected = true;
  //late List incomeChartData;
  List<Map<String, dynamic>> incomeChartData = [];
  //late List expenseChartData;
  List<Map<String, dynamic>> expenseChartData = [];
  late List incomeList;
  late List expenseList;
  late double totalIncome;
  late double totalExpense;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    incomeChartData = [];
    expenseChartData = [];
    incomeList = [];
    expenseList = [];
    totalIncome = 0;
    totalExpense = 0;
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
      body: widget.user.id == "unregistered"
          ? Center(
              child: Text(
                'Please register to access statistic reports.',
                style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
              ),
            )
          : Column(
              children: [
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
                            await _showMonthPicker(
                                context); // Call your function
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
                const Divider(height: 1),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isIncomeSelected = true;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isIncomeSelected
                                ? Color.fromARGB(255, 255, 245, 230)
                                : Color.fromARGB(255, 255, 245, 230),
                            border: Border(
                              bottom: BorderSide(
                                color: _isIncomeSelected
                                    ? Colors.orange
                                    : Colors.transparent,
                                width:
                                    2, // Adjust the width of the bottom border as needed
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: Text(
                                'Income',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _isIncomeSelected
                                      ? Colors.black
                                      : Colors.grey,
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
                            _isIncomeSelected = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isIncomeSelected
                                ? Color.fromARGB(255, 255, 245, 230)
                                : Color.fromARGB(255, 255, 245, 230),
                            border: Border(
                              bottom: BorderSide(
                                color: _isIncomeSelected
                                    ? Colors.transparent
                                    : Colors.orange,
                                width:
                                    2, // Adjust the width of the bottom border as needed
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: Text(
                                'Expense',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _isIncomeSelected
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildChart(), // method to build pie chart
                      //SizedBox(height: 20),
                      _buildCategoryList(), // method to build list of categories
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _goToPreviousMonth() {
    if (!_isDisposed) {
      setState(() {
        _selectedMonth =
            DateTime(_selectedMonth.year, _selectedMonth.month - 1);
        incomeChartData = [];
        expenseChartData = [];
        incomeList = [];
        expenseList = [];
        totalIncome = 0;
        totalExpense = 0;
        _loadData(_selectedMonth.year, _selectedMonth.month);
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
          // Reload records for the selected month
          incomeChartData = [];
          expenseChartData = [];
          incomeList = [];
          expenseList = [];
          totalIncome = 0;
          totalExpense = 0;
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
        // Reload records for the new selected month
        incomeChartData = [];
        expenseChartData = [];
        incomeList = [];
        expenseList = [];
        totalIncome = 0;
        totalExpense = 0;
        _loadData(_selectedMonth.year, _selectedMonth.month);
      });
    }
  }

  Widget _buildChart() {
    List<Map<String, dynamic>> data =
        _isIncomeSelected ? incomeChartData : expenseChartData;

    // Sort the data list in descending order based on the 'amount'
    data.sort((a, b) =>
        double.parse(b['amount']).compareTo(double.parse(a['amount'])));

    // Generate segment colors for pie chart based on sorted category list
    List<Color> segmentColors = _generateSegmentColors(data);

    return Container(
      color: Color.fromARGB(255, 255, 245, 230),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: List.generate(
                data.length,
                (index) => PieChartSectionData(
                  color: segmentColors[index], // Use color from the list
                  value: double.parse(data[index]['percentage']),
                  // title: '${data[index]['category']}',
                  showTitle: false,
                  radius: 100,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              centerSpaceRadius: 0,
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _generateSegmentColors(List<Map<String, dynamic>> data) {
    List<Color> colors = [];
    final double baseHue = 10; // Start with a blue hue
    final double hueStep = 12; // Smaller step for subtle variations

    for (int i = 0; i < data.length; i++) {
      final double hue = baseHue + (hueStep * i);
      final Color color = _hslToColor(hue, 0.7 + (0.1 * i),
          0.5); // Adjust saturation slightly for each segment
      colors.add(color);
    }
    return colors;
  }

// Helper function to convert HSL values to Color
  Color _hslToColor(double hue, double saturation, double lightness) {
    final double chroma = (1 - (2 * lightness - 1).abs()) * saturation;
    final double huePrime = hue / 60.0;
    final double secondComponent = chroma * (1 - ((huePrime % 2) - 1).abs());

    double red, green, blue;

    if (0 <= huePrime && huePrime < 1) {
      red = chroma;
      green = secondComponent;
      blue = 0.0;
    } else if (1 <= huePrime && huePrime < 2) {
      red = secondComponent;
      green = chroma;
      blue = 0.0;
    } else if (2 <= huePrime && huePrime < 3) {
      red = 0.0;
      green = chroma;
      blue = secondComponent;
    } else if (3 <= huePrime && huePrime < 4) {
      red = 0.0;
      green = secondComponent;
      blue = chroma;
    } else if (4 <= huePrime && huePrime < 5) {
      red = secondComponent;
      green = 0.0;
      blue = chroma;
    } else if (5 <= huePrime && huePrime < 6) {
      red = chroma;
      green = 0.0;
      blue = secondComponent;
    } else {
      red = 0.0;
      green = 0.0;
      blue = 0.0;
    }

    final double lightnessAdjustment = lightness - chroma / 2;
    red += lightnessAdjustment;
    green += lightnessAdjustment;
    blue += lightnessAdjustment;

    return Color.fromRGBO(
        (red * 255).round(), (green * 255).round(), (blue * 255).round(), 1.0);
  }

  List<Color> _getDefaultColors(int count) {
    List<Color> defaultColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.deepPurple,
      Colors.lime,
      Colors.cyan,
      Colors.lightBlue,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
    ];
    // Cycle through default colors to match the count
    List<Color> result = [];
    for (int i = 0; i < count; i++) {
      result.add(defaultColors[i % defaultColors.length]);
    }
    return result;
  }

  Widget _buildCategoryList() {
    List<Map<String, dynamic>> data =
        _isIncomeSelected ? incomeChartData : expenseChartData;

    // Sort the data list in descending order based on the 'amount'
    data.sort((a, b) =>
        double.parse(b['amount']).compareTo(double.parse(a['amount'])));

    print(data.length);
    // Build and return the list of categories with their data
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          Container(
            color: Color.fromARGB(255, 255, 227, 186),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isIncomeSelected ? 'Total Income: ' : 'Total Expense: ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Text(
                    _isIncomeSelected
                        ? '$currency ${totalIncome.toStringAsFixed(2)}'
                        : '$currency ${totalExpense.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              //shrinkWrap: true,
              //physics: NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final Color sectionColor = _generateSegmentColors(data)[index];
                return Container(
                  color: Color.fromARGB(255, 255, 245, 230),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        leading: Container(
                          width: 60,
                          height: 30,
                          decoration: BoxDecoration(
                            color: sectionColor, // Use section color here
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${data[index]['percentage']}%',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        title: Text(data[index]['category']),
                        trailing: Text('$currency ${data[index]['amount']}',
                            style: TextStyle(
                                fontSize: 15,
                                color: _isIncomeSelected
                                    ? Colors.black
                                    : Colors.black)),
                      ),
                      const Divider(height: 1),
                    ],
                  ),
                );
              },
              padding: const EdgeInsets.only(bottom: 80),
            ),
          ),
        ],
      ),
    );
  }

  void _loadData(int year, int month) async {
    if (widget.user.id == "unregistered") {
      if (!_isDisposed) {
        setState(() {
          titlecenter = "No Records Found";
        });
      }

      return;
    }

    await _loadIncome(year, month);
    await _loadExpense(year, month);
    _calculateTotalIncome();
    _calculateTotalExpense();
    _populateChartData();
    if (!_isDisposed) {
      setState(() {});
    }
    // Refresh UI after loading data
  }

  Future<void> _loadIncome(int year, int month) async {
    await http.post(Uri.parse("${MyConfig.server}/mypfm/php/loadIncome.php"),
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
            incomeList = extractdata;
          });
        }
      } else if (response.statusCode == 200 && jsondata['status'] == 'failed') {
        // Handle case when no records are found
        if (!_isDisposed) {
          setState(() {
            titlecenter = "No Records Found";
            incomeList = []; // Clear existing data
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

  Future<void> _loadExpense(int year, int month) async {
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
            expenseList = extractdata;
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
    });
  }

  void _calculateTotalIncome() {
    totalIncome = incomeList.fold(
        0,
        (previous, current) =>
            previous + double.parse(current['income_amount']));
    print('TotalIncome: $totalIncome');
  }

  void _calculateTotalExpense() {
    totalExpense = expenseList.fold(
        0,
        (previous, current) =>
            previous + double.parse(current['expense_amount']));
    print('TotalExpense: $totalExpense');
  }

  void _populateChartData() {
    incomeChartData.clear();
    expenseChartData.clear();

    // Group income data by category and calculate total amount for each category
    incomeList.forEach((income) {
      var index = incomeChartData.indexWhere(
          (element) => element['category'] == income['income_category']);
      if (index != -1) {
        // Ensure the 'amount' field is stored as a double
        double currentAmount = double.parse(incomeChartData[index]['amount']);
        double newAmount =
            currentAmount + double.parse(income['income_amount']);
        incomeChartData[index]['amount'] = newAmount
            .toStringAsFixed(2); // Convert back to string with 2 decimal places
      } else {
        // Add a new entry for the category with the parsed income amount
        incomeChartData.add({
          'category': income['income_category'],
          'amount': double.parse(income['income_amount'])
              .toStringAsFixed(2), // Parse to double and then to string
          'percentage': 0
        });
      }
    });

    // Group expense data by category and calculate total amount for each category
    expenseList.forEach((expense) {
      var index = expenseChartData.indexWhere(
          (element) => element['category'] == expense['expense_category']);
      if (index != -1) {
        // Ensure the 'amount' field is stored as a double
        double currentAmount = double.parse(expenseChartData[index]['amount']);
        double newAmount =
            currentAmount + double.parse(expense['expense_amount']);
        expenseChartData[index]['amount'] = newAmount
            .toStringAsFixed(2); // Convert back to string with 2 decimal places
      } else {
        // Add a new entry for the category with the parsed expense amount
        expenseChartData.add({
          'category': expense['expense_category'],
          'amount': double.parse(expense['expense_amount'])
              .toStringAsFixed(2), // Parse to double and then to string
          'percentage': 0
        });
      }
    });

    _calculatePercentage();
  }

  void _calculatePercentage() {
    incomeChartData.forEach((data) {
      double amount = double.parse(data['amount']);
      double percentage = (amount / totalIncome) * 100;
      data['percentage'] = percentage.toStringAsFixed(2);
      data['amount'] =
          amount.toStringAsFixed(2); // Convert amount back to string
    });

    expenseChartData.forEach((data) {
      double amount = double.parse(data['amount']);
      double percentage = (amount / totalExpense) * 100;
      data['percentage'] = percentage.toStringAsFixed(2);
      data['amount'] =
          amount.toStringAsFixed(2); // Convert amount back to string
    });
  }
}
