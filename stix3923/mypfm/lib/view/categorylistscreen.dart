import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class CategoryListScreen extends StatefulWidget {
  final User user;
  final String selectedType;
  const CategoryListScreen(
      {Key? key, required this.user, required this.selectedType})
      : super(key: key);

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  List<String> categories = [];
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    fetchCat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedType,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          String categoryName = categories[index];
          return ListTile(
            leading: const Icon(Icons.remove_circle_rounded,
                color: Colors.red), // Red minus icon
            title: Text(categoryName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    // Handle edit button press for the category
                    _editCategoryName(categoryName);
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> fetchCat() async {
    try {
      if (widget.selectedType == "Expense") {
        // Fetch expense categories
        final exCatResponse = await http.post(
          Uri.parse("${MyConfig.server}/mypfm/php/getExCat.php"),
          body: {"user_id": widget.user.id},
        );
        if (exCatResponse.statusCode == 200) {
          final dynamic exCatData =
              jsonDecode(exCatResponse.body)['categories'];
          final List<String> exCatList =
              (exCatData as List).cast<String>(); // Cast to List<String>
          setState(() {
            categories = exCatList;
          });
        }
        print(categories);
      } else {
        // Fetch income categories
        final inCatResponse = await http.post(
          Uri.parse("${MyConfig.server}/mypfm/php/getInCat.php"),
          body: {"user_id": widget.user.id},
        );
        if (inCatResponse.statusCode == 200) {
          final dynamic inCatData =
              jsonDecode(inCatResponse.body)['categories'];
          final List<String> inCatList =
              (inCatData as List).cast<String>(); // Cast to List<String>
          setState(() {
            categories = inCatList;
          });
        }
        print(categories);
      }
    } catch (e) {
      logger.e("Error fetching categories: $e");
    }
  }

  void _editCategoryName(String categoryName) {
    String url = "";
    final TextEditingController _categoryController =
        TextEditingController(text: categoryName);
    String newCategoryName = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit'),
          content: TextField(
            controller: _categoryController,
            decoration: InputDecoration(hintText: categoryName),
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
                  newCategoryName = _categoryController.text;
                });
                // Validate if the category name is not empty
                if (newCategoryName.isNotEmpty) {
                  // Validate if the category name is not already in the list
                  if (!categories.contains(newCategoryName)) {
                    if (widget.selectedType == "Income") {
                      url = "${MyConfig.server}/mypfm/php/editInCat.php";
                    } else {
                      url = "${MyConfig.server}/mypfm/php/editExCat.php";
                    }
                    print(widget.user.id);
                    print("Check selected category: $categoryName");
                    print("Check new category: $newCategoryName");
                    // Add logic to add new category to the database
                    try {
                      final response = await http.post(
                        Uri.parse(url),
                        body: {
                          "user_id": widget.user.id,
                          "incat_name": categoryName,
                          "new_name": newCategoryName
                        },
                      );
                      if (response.statusCode == 200) {
                        // Category added successfully
                        var data = jsonDecode(response.body);
                        print(data);
                        if (data['status'] == 'success') {
                          setState(() {
                            categories.remove(
                                categoryName); // Remove old category name
                            categories
                                .add(newCategoryName); // Add new category name
                          });
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                              msg: "Edit Category Success.",
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
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
