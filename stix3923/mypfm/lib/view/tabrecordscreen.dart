import 'package:flutter/material.dart';

class TabRecordScreen extends StatefulWidget {
  const TabRecordScreen({super.key});

  @override
  State<TabRecordScreen> createState() => _TabRecordScreenState();
}

class _TabRecordScreenState extends State<TabRecordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Record",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade100,
        centerTitle: true,
      ),
      body: Center(
        child: Text("Record Page"),
      ),
      endDrawer: Drawer(
        // Use endDrawer instead of drawer
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
                  // Profile Icon
                  CircleAvatar(
                    backgroundColor:
                        Colors.orange, // Background color of the circle
                    radius: 20, // Adjust the size as needed
                    child: Icon(
                      Icons.person, // Choose the desired icon
                      color: Colors.white, // Color of the icon
                      size: 24, // Size of the icon
                    ),
                  ),
                  // Name and Email
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
                  // Edit Button
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
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
    );
  }
}
