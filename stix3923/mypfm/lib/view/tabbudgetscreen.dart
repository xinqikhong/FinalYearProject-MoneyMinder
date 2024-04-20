import 'package:flutter/material.dart';

class TabBudgetScreen extends StatefulWidget {
  const TabBudgetScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<TabBudgetScreen> createState() => _TabBudgetScreenState();
}

class _TabBudgetScreenState extends State<TabBudgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(widget.title),
    );
  }
}
