import 'package:flutter/material.dart';
import 'package:homerroxproject/Screen/HomePage/Components/AppBar.dart';
import 'package:homerroxproject/Screen/HomePage/Components/HomePageBody.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: const HomePageBody(),
    );
  }
}
