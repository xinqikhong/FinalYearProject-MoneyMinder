import 'package:flutter/material.dart';
import 'package:mypfm/model/user.dart';

class TabReportScreen extends StatefulWidget {
  final User user;
  const TabReportScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TabReportScreen> createState() => _TabReportScreenState();
}

class _TabReportScreenState extends State<TabReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("widget.title"),
    );
  }
}
