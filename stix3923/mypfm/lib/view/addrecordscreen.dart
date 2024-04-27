import 'package:flutter/material.dart';
import 'package:mypfm/model/user.dart';

class AddRecordScreen extends StatefulWidget {
  final User user;
  const AddRecordScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  String selectedType = "Expense"; // Initial selected type
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> categories = [
    "Food",
    "Rent",
    "Bills",
    "Transportation",
    "Entertainment",
    "Other"
  ];

  final List<String> accounts = ["Cash", "Bank Account", "E-wallet", "Other"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Add Record",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Row for Income/Expense buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedType = "Income";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedType == "Income"
                            ? Colors.green
                            : Colors.grey[
                                200], // Set button color based on selection
                      ),
                      child: Text(
                        "Income",
                        style: TextStyle(
                            color: selectedType == "Income"
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedType = "Expense";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedType == "Expense"
                            ? Colors.red
                            : Colors.grey[
                                200], // Set button color based on selection
                      ),
                      child: Text(
                        "Expense",
                        style: TextStyle(
                            color: selectedType == "Expense"
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0), // Add spacing

                // Form fields
                TextFormField(
                  controller: _dateController,
                  readOnly: true, // Make date field read-only
                  decoration: const InputDecoration(
                    labelText: "Date",
                    icon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    // Handle date selection using a date picker package (not included here)
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023, 1, 1),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dateController.text = pickedDate.toString();
                      });
                    }
                  },
                  validator: (value) =>
                      value!.isEmpty ? "Please select a date" : null,
                ),
                const SizedBox(height: 10.0),

                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    icon: Icon(Icons.attach_money),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter amount" : null,
                ),
                const SizedBox(height: 10.0),

                TextFormField(
                  readOnly: true, // Make category field read-only
                  decoration: const InputDecoration(
                    labelText: "Category",
                    icon: Icon(Icons.category), // Optional icon for the field
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => CategorySelectionBottomSheet(
                        categories: categories, // Pass your categories list
                        onCategorySelected: (selectedCategory) {
                          setState(() {
                            _categoryController.text = selectedCategory;
                          });
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10.0),

                TextFormField(
                  readOnly: true, // Make account field read-only
                  decoration: const InputDecoration(
                    labelText: "Account",
                    icon: Icon(
                        Icons.account_balance), // Optional icon for the field
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => AccountSelectionBottomSheet(
                        accounts: accounts, // Pass your accounts list
                        onAccountSelected: (selectedAccount) {
                          setState(() {
                            _accountController.text = selectedAccount;
                          });
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10.0),

                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: "Note (Optional)",
                    icon: Icon(Icons.note_alt_outlined),
                  ),
                ),
                const SizedBox(height: 10.0),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3, // Allow multiple lines for description
                  decoration: const InputDecoration(
                    labelText: "Description (Optional)",
                    icon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Row for Save and Cancel buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Handle form submission (save record)
                          // This would involve saving the data (type, date, amount, category, account, note, description) to your database or storage solution.
                          print(
                              "Record saved!"); // Placeholder for actual saving logic
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.white, // Set your desired background color
                        foregroundColor:
                            Colors.orange, // Set your desired text color
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Clear Form"),
                            content: const Text(
                                "Are you sure you want to clear all form data?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _formKey.currentState!.reset();
                                  Navigator.pop(
                                      context); // Close screen after clearing
                                },
                                child: const Text("Yes"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context), // Dismiss dialog
                                child: const Text("No"),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.white, // Set your desired background color
                        foregroundColor:
                            Colors.orange, // Set your desired text color
                      ),
                      child: const Text(
                        "Clear",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategorySelectionBottomSheet extends StatefulWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;

  const CategorySelectionBottomSheet({
    Key? key,
    required this.categories,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategorySelectionBottomSheet> createState() =>
      _CategorySelectionBottomSheetState();
}

class _CategorySelectionBottomSheetState
    extends State<CategorySelectionBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Set background color
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Add some padding
        child: Column(
          mainAxisSize: MainAxisSize.min, // Set minimum height
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Category",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () =>
                      Navigator.pop(context), // Close the bottom sheet
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(), // Add a divider line
            Expanded(
              // Allows the content to fill the remaining space
              child: GridView.count(
                crossAxisCount: 3, // 4 categories per row
                children: widget.categories
                    .map((category) => _CategoryItem(
                          category: category,
                          onPressed: () {
                            widget.onCategorySelected(category);
                            Navigator.pop(context); // Close after selection
                          },
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 10.0), // Add a little spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  onPressed: () {
                    // Handle "Add" button press (navigate to add category screen or implement logic here)
                    // You might need to open another screen for adding a category
                    print(
                        "Add Category button pressed!"); // Placeholder for now
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String category;
  final Function() onPressed;

  const _CategoryItem({
    Key? key,
    required this.category,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace with your actual category icons (consider using a package for icons)
    final icon = Icon(Icons.category); // Placeholder icon for now
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(category),
    );
  }
}

class AccountSelectionBottomSheet extends StatefulWidget {
  final List<String> accounts; // List of predefined accounts
  final Function(String) onAccountSelected;

  const AccountSelectionBottomSheet({
    Key? key,
    required this.accounts,
    required this.onAccountSelected,
  }) : super(key: key);

  @override
  State<AccountSelectionBottomSheet> createState() =>
      _AccountSelectionBottomSheetState();
}

class _AccountSelectionBottomSheetState
    extends State<AccountSelectionBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Set background color
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Add some padding
        child: Column(
          mainAxisSize: MainAxisSize.min, // Set minimum height
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Account",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () =>
                      Navigator.pop(context), // Close the bottom sheet
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(), // Add a divider line
            Expanded(
              // Allows the content to fill the remaining space
              child: GridView.count(
                crossAxisCount: 3, // 3 accounts per row
                children: widget.accounts
                    .map((account) => _AccountItem(
                          account: account,
                          onPressed: () {
                            widget.onAccountSelected(account);
                            Navigator.pop(context); // Close after selection
                          },
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 10.0), // Add a little spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  onPressed: () {
                    // Handle "Add" button press (navigate to add account screen or implement logic here)
                    // You might need to open another screen for adding an account
                    print("Add Account button pressed!"); // Placeholder for now
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  final String account;
  final Function() onPressed;

  const _AccountItem({
    Key? key,
    required this.account,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace with your actual account icons (consider using a package for icons)
    final icon = Icon(Icons.account_balance); // Placeholder icon for now
    return ClipRRect(
      // Add rounded corners
      borderRadius: BorderRadius.circular(10.0),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(account),
      ),
    );
  }
}
