import 'package:flutter/material.dart';

class TabBudgetScreen extends StatefulWidget {
  const TabBudgetScreen({super.key});

  @override
  State<TabBudgetScreen> createState() => _TabBudgetScreenState();
}

class _TabBudgetScreenState extends State<TabBudgetScreen> {
  @override
  Widget build(BuildContext context) {
    return  const Scaffold(
      body: Center(child: Text("Budget Screen",))
    );
  }
}