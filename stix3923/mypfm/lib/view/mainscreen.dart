import 'package:flutter/material.dart';
import 'package:mypfm/model/user.dart';
import 'package:mypfm/view/registerscreen.dart';
import 'package:mypfm/view/tabbudgetscreen.dart';
import 'package:mypfm/view/tabrecordscreen.dart';
import 'package:mypfm/view/tabreportscreen.dart';
import 'package:mypfm/view/tabresourcescreen.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  //can delete, just want to test user object succesfully pass or not
  @override
  void initState() {
    super.initState();
    // Print output to the console
    print(widget.user.name);
  }

  int _currentIndex = 0;
  String maintitle = "Record";

  // List of tab screens
  final List<Widget> _tabScreens = [
    const TabRecordScreen(title: 'Record'),
    const TabBudgetScreen(title: 'Budget'),
    const TabReportScreen(title: 'Report'),
    const TabResourceScreen(title: 'Resource'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          maintitle,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ), // Dynamic title
        backgroundColor: Colors.orange.shade100,
        centerTitle: true,
      ),
      body: _tabScreens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
        showUnselectedLabels: true,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore_outlined),
            label: 'Resource',
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    radius: 20,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'User Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'user@example.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Add edit button functionality here
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Manage Account'),
              onTap: () {
                // Handle "Manage Account" tap if needed
              },
              trailing: PopupMenuButton<String>(
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'change_password',
                    child: const Text('Change Password'),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete_account',
                    child: const Text('Delete Account'),
                  ),
                ],
                onSelected: (String value) {
                  // Handle submenu item selection
                  switch (value) {
                    case 'profile':
                      // Handle Profile submenu tap
                      break;
                    case 'change_password':
                      // Handle Change Password submenu tap
                      break;
                    case 'delete_account':
                      // Handle Delete Account submenu tap
                      break;
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Language Setting'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Currency Setting'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Log Out'),
              onTap: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // Return AlertDialog with the confirmation message
                    return AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text('Do you want to log out?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            // Navigate to the register screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Dismiss the dialog
                            Navigator.pop(context);
                          },
                          child: const Text('No'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 0) {
        maintitle = "Record";
      }
      if (_currentIndex == 1) {
        maintitle = "Budget";
      }
      if (_currentIndex == 2) {
        maintitle = "Report";
      }
      if (_currentIndex == 3) {
        maintitle = "Resource";
      }
    });
  }
}
