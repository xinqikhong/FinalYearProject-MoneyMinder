import 'package:flutter/material.dart';
import 'package:mypfm/model/user.dart';

class TabStatsScreen extends StatefulWidget {
  final User user;
  const TabStatsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TabStatsScreen> createState() => _TabStatsScreenState();
}

class _TabStatsScreenState extends State<TabStatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Stats"),
    );
  }
}
