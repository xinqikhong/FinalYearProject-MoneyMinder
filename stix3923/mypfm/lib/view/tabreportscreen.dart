import 'package:flutter/material.dart';

class TabReportScreen extends StatefulWidget {
  const TabReportScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<TabReportScreen> createState() => _TabReportScreenState();
}

class _TabReportScreenState extends State<TabReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(widget.title),
    );
  }
}
