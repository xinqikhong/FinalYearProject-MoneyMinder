import 'package:flutter/material.dart';
import 'package:mypfm/model/user.dart';

class TabRecordScreen extends StatefulWidget {
  final User user;
  const TabRecordScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TabRecordScreen> createState() => _TabRecordScreenState();
}

class _TabRecordScreenState extends State<TabRecordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Pagination for months
          Container(
            height: 50, // Adjust height as needed
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    // Previous month logic
                  },
                  icon: Icon(Icons.arrow_back),
                ),
                Text('Selected Month'), // Display selected month
                IconButton(
                  onPressed: () {
                    // Next month logic
                  },
                  icon: Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
          // Total income and expenses
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Income: \$XXXX'),
                Text('Total Expense: \$XXXX'),
              ],
            ),
          ),
          // Record list
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Replace with actual record count
              itemBuilder: (context, index) {
                // Replace with record widget
                return ListTile(
                  leading: Icon(Icons.attach_money),
                  title: Text('Record Title'),
                  subtitle: Text('Record Category'),
                  trailing: Text(
                    '\$XXX.XX',
                    style: TextStyle(
                      color: Colors.blue, // For income
                    ),
                  ),
                  onTap: () {
                    // Record tap logic
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add record logic
        },
        child: Icon(Icons.add),
        tooltip: "Add Record",
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Adjust the value as needed
        ),
      ),
    );
  }
}
