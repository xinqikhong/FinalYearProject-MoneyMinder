import 'package:flutter/material.dart';

class TabResourceScreen extends StatefulWidget {
  const TabResourceScreen({super.key});

  @override
  State<TabResourceScreen> createState() => _TabResourceScreenState();
}

class _TabResourceScreenState extends State<TabResourceScreen> {
  @override
  Widget build(BuildContext context) {
    return  const Scaffold(
      body: Center(child: Text("Resource Screen",))
    );
  }
}