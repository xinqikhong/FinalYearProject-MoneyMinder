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
            height: 40, // Adjust height as needed
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
          Divider(),
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
              child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and totals
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      'Day X', // Replace with actual day
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Income: \$XXX.XX'), // Replace with actual total income
                      Text(
                          'Expense: \$XXX.XX'), // Replace with actual total expense
                    ],
                  ),
                  Divider(), // Divider between totals and records
                  // Individual records
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 5, // Replace with actual record count
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.attach_money),
                        title: Text(
                            'Record Title'), // Replace with actual record title
                        subtitle: Text(
                            'Record Category'), // Replace with actual record category
                        trailing: Text(
                          '\$XXX.XX',
                          style: TextStyle(
                            color: Colors.blue, // For income
                          ),
                        ), // Replace with actual record amount
                        onTap: () {
                          // Record tap logic
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          )),
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
