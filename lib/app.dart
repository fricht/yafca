import 'package:flutter/material.dart';
import 'package:yafca/utils.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int _currentIndex = 0;

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("YAFCA"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: setCurrentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Topics"),
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: "Archives"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showSnackBar(context, Text("Current index : $_currentIndex"));
        },
      ),
    );
  }
}
