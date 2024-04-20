import 'package:flutter/material.dart';

class TabResourceScreen extends StatefulWidget {
  const TabResourceScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<TabResourceScreen> createState() => _TabResourceScreenState();
}

class _TabResourceScreenState extends State<TabResourceScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(widget.title),
    );
  }
}
