import 'package:flutter/material.dart';
import 'package:mypfm/model/user.dart';
import 'package:mypfm/view/addrecordscreen.dart';
import 'package:mypfm/view/registerscreen.dart';

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
          Center(
            child: Container(
              height: 40, // Adjust height as needed
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      // Previous month logic
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Text(
                    'Selected Month',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ), // Display selected month
                  IconButton(
                    onPressed: () {
                      // Next month logic
                    },
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
              itemCount: 5, // Replace with actual number of days in a month
              itemBuilder: (context, index) {
                return _buildDailyRecord(index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _handleAddRecordBtn();
        },
        child: const Icon(Icons.add),
        tooltip: "Add Record",
        //backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Adjust the value as needed
        ),
      ),
    );
  }

  Widget _buildDailyRecord(int index) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 10),
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
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                'Day ${index + 1}', // Replace with actual day
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Income: \$XXX.XX'), // Replace with actual total income
                Text('Expense: \$XXX.XX'), // Replace with actual total expense
              ],
            ),
            const Divider(), // Divider between totals and records
            // Individual records
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5, // Replace with actual record count
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text(
                      'Record Title'), // Replace with actual record title
                  subtitle: const Text(
                      'Record Category'), // Replace with actual record category
                  trailing: const Text(
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
    );
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
}
