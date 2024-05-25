import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mypfm/model/config.dart';
import 'package:mypfm/model/user.dart';
import 'package:mypfm/view/changepasswordscreen.dart';
import 'package:mypfm/view/currencysettingscreen.dart';
import 'package:mypfm/view/editprofilescreen.dart';
import 'package:mypfm/view/loginscreen.dart';
import 'package:mypfm/view/registerscreen.dart';
import 'package:mypfm/view/tabbudgetscreen.dart';
import 'package:mypfm/view/tabrecordscreen.dart';
import 'package:mypfm/view/tabstatsscreen.dart';
import 'package:mypfm/view/tabresourcescreen.dart';
import 'package:ndialog/ndialog.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'currency_provider.dart';

class MainScreen extends StatefulWidget {
  final User user;
  final CurrencyProvider currencyProvider;
  const MainScreen({Key? key, required this.user, required this.currencyProvider}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late List<Widget> tabScreens;
  int _currentIndex = 0;
  String maintitle = "Record";
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    // Print output to the console
    print(widget.user.name);
    tabScreens = [
      TabRecordScreen(user: widget.user, currencyProvider: widget.currencyProvider),
      TabBudgetScreen(user: widget.user, currencyProvider: widget.currencyProvider),
      TabStatsScreen(user: widget.user, currencyProvider: widget.currencyProvider),
      TabResourceScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          maintitle,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize:
              Size.fromHeight(4.0), // Adjust the height of the divider
          child: Divider(
            color: Colors.grey, // Adjust the color of the divider
            height: 4.0, // Adjust the thickness of the divider
          ),
        ),
      ),
      body: tabScreens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle:
            const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
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
            label: 'Stats',
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.orange,
                      radius: 20,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      //flex: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.user.name.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                            //textAlign: TextAlign.center,
                          ),
                          Text(
                            widget.user.email.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                            //textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: widget.user.id != "unregistered"
                          ? _handleEditProfileBtn
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              enabled: widget.user.id != "unregistered",
              title: const Text(
                'Manage Account',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // Handle "Manage Account" tap if needed
              },
              trailing: PopupMenuButton<String>(
                enabled: widget.user.id != "unregistered",
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'change_password',
                    child: Text('Change Password'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete_account',
                    child: Text('Delete Account'),
                  ),
                ],
                onSelected: (String value) async {
                  // Handle submenu item selection
                  switch (value) {
                    /*case 'profile':
                      // Handle Profile submenu tap
                      break;*/
                    case 'change_password':
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChangePasswordScreen(user: widget.user),
                        ),
                      );
                      break;
                    case 'delete_account':
                      _deleteAccountDialog();
                      break;
                  }
                },
              ),
            ),
            /*ListTile(
              title: const Text('Language Setting'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),*/
            ListTile(
              enabled: widget.user.id != "unregistered",
              title: const Text(
                'Currency Setting',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CurrencySettingScreen()),
              ),
            ),
            ListTile(
              title: widget.user.id == "unregistered"
                  ? const Text(
                      'Register Here',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Text('Log Out',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
              onTap: () {
                if (widget.user.id == "unregistered") {
                  // Navigate to the RegisterScreen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                } else {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // Return AlertDialog with the confirmation message
                      return Theme(
                        data: ThemeData(
                          // Set button color to match your app's primary color
                          primaryColor: Theme.of(context).primaryColor,
                        ),
                        child: AlertDialog(
                          title: const Text('Log Out'),
                          content: const Text(
                            'Are you sure?',
                            style: TextStyle(
                              fontSize: 18, // Adjust the font size as needed
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                // Navigate to the register screen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).primaryColor,
                              ),
                              child: const Text(
                                'Yes',
                                style: TextStyle(
                                  fontSize:
                                      18, // Adjust the font size as needed
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Dismiss the dialog
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).primaryColor,
                              ),
                              child: const Text(
                                'No',
                                style: TextStyle(
                                  fontSize:
                                      18, // Adjust the font size as needed
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
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
        maintitle = "Statistics";
      }
      if (_currentIndex == 3) {
        maintitle = "Resource";
      }
    });
  }

  void _handleEditProfileBtn() {
    if (widget.user.id == "unregistered") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Register to Edit Profile'),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content:
                const Text('You need to register first to edit your profile.'),
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
      // Navigate to EditProfileScreen for registered users
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfileScreen(user: widget.user),
        ),
      );
    }
  }

  void _deleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Delete account",
            style: TextStyle(),
          ),
          content: const Text(
              "Are you sure?\nThis action is irreversible and will permanently remove all your data.",
              style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount() async {
    print('start _deleteAccount()');
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Delete account in progress.."),
        title: const Text("Deleting..."));
    progressDialog.show();
    await http.post(
        Uri.parse("${MyConfig.server}/mypfm/php/deleteUserAccount.php"),
        body: {
          "user_id": widget.user.id,
        }).then((response) {
      progressDialog.dismiss();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          Fluttertoast.showToast(
              msg: "Account has been deleted.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const RegisterScreen(),
            ),
          );
        } else {
          print(response.body);
          Fluttertoast.showToast(
              msg: data['message'] ?? "Delete Account Failed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          return;
        }
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
      }
    }).catchError((error) {
      progressDialog.dismiss();
      logger.e("An error occurred: $error");
      Fluttertoast.showToast(
          msg: "An error occurred: $error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    });
  }
}
