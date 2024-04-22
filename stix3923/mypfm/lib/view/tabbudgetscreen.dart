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
    return Center(
      child: Text("widget.title"),
    );
  }
}
