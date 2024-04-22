import 'package:flutter/material.dart';
import 'package:mypfm/model/user.dart';

class TabResourceScreen extends StatefulWidget {
  final User user;
  const TabResourceScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TabResourceScreen> createState() => _TabResourceScreenState();
}

class _TabResourceScreenState extends State<TabResourceScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("widget.title"),
    );
  }
}
