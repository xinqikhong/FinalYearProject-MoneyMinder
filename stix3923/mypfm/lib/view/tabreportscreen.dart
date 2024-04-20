import 'package:flutter/material.dart';

class TabReportScreen extends StatefulWidget {
  const TabReportScreen({super.key});

  @override
  State<TabReportScreen> createState() => _TabReportScreenState();
}

class _TabReportScreenState extends State<TabReportScreen> {
  @override
  Widget build(BuildContext context) {
    return  const Scaffold(
      body: Center(child: Text("Report Screen",))
    );
  }
}