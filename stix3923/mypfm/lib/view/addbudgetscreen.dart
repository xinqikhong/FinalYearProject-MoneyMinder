import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:mypfm/view/addbudgetdetailscreen.dart';

class AddBudgetScreen extends StatefulWidget {
  final User user;
  //final List budgetlist;
  final DateTime selectedMonth;
  const AddBudgetScreen(
      {Key? key,
      required this.user,
      //required this.budgetlist,
      required this.selectedMonth})
      : super(key: key);

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  List budgetlist = [];
  List excatlist = [];
  List displayCat = [];
  var logger = Logger();
  var selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadBudget(widget.selectedMonth.year,widget.selectedMonth.month);     
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Budget",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          excatlist.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayCat.length,
                  itemBuilder: (context, index) {
                    String categoryName = displayCat[index];
                    return Container(
                      color: const Color.fromARGB(255, 255, 245, 230),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(categoryName),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    // Handle edit button press for the category
                                    String selectedCategory = categoryName;
                                    _addBudget(selectedCategory);
                                  },
                                  icon: const Icon(
                                    Icons.add_circle,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  void _loadExCat() async {
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
        _loadDisplayCat();
      }
      print(excatlist);
    } catch (e) {
      logger.e("Error fetching categories: $e");
    }
  }

  void _addBudget(String selectedCategory) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBudgetDetailScreen(
            user: widget.user,
            selectedMonth: widget.selectedMonth,
            selectedCategory: selectedCategory),
      ),
    );
    _loadBudget(widget.selectedMonth.year,widget.selectedMonth.month);
  }

  void _loadDisplayCat() {
    List<String> newDisplayCat = [];

    // Iterate through excatlist and add items to newDisplayCat if they are not in widget.budgetlist
    for (String categoryName in excatlist) {
      bool categoryExists = budgetlist
          .any((budget) => budget['budget_category'] == categoryName);
      if (!categoryExists) {
        newDisplayCat.add(categoryName);
      }
    }

    setState(() {
      displayCat = newDisplayCat; // Update displayCat with the new list
    });

    print(displayCat);
  }
  
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
        _loadExCat();
      } else if (response.statusCode == 200 && jsondata['status'] == 'failed') {
        // Handle case when no records are found
        Fluttertoast.showToast(
          msg: "An error occurred.\nPlease try again later.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
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
}
