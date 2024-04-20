import 'package:flutter/material.dart';

class TabRecordScreen extends StatefulWidget {
  const TabRecordScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<TabRecordScreen> createState() => _TabRecordScreenState();
}

class _TabRecordScreenState extends State<TabRecordScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(widget.title),
    );
  }
}
