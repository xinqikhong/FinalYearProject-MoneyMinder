import 'package:flutter/material.dart';
import 'package:mypfm/model/user.dart';

class TabBudgetScreen extends StatefulWidget {
  final User user;
  const TabBudgetScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TabBudgetScreen> createState() => _TabBudgetScreenState();
}

class _TabBudgetScreenState extends State<TabBudgetScreen> {
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
                Text(
                  'Selected Month',
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ), // Display selected month
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
          // Budget list
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                itemCount: 10, // Replace with actual category count
                itemBuilder: (context, index) {
                  // Replace with budget widget
                  return ListTile(
                    title: Text('Category $index'),
                    subtitle:
                        Text('Budget: \$XXX.XX'), // Replace with actual budget
                    trailing: Text(
                      'Expenses: \$XXX.XX', // Replace with actual expenses
                      style: TextStyle(
                        color: Colors.red, // For expenses
                      ),
                    ),
                    onTap: () {
                      // Budget tap logic
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
