import 'package:flutter/material.dart';
import 'package:yafca/add_question.dart';
import 'package:yafca/subject_list.dart';
import 'package:yafca/test/create_test_page.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int currentIndex = 3;

  void setCurrentIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  FloatingActionButton genFABArchivedPreset(bool archived) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AddQuestion(archived))
        ).then((_) {setState(() {currentIndex = 0;});});
        // TODO : find a method to refresh the current list instead of returning to the test page
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("YAFCA"),
      ),
      body: const [CreateTestPage(), SubjectList(false, key: ValueKey("Topics")), SubjectList(true, key: ValueKey("Archives")), null][currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: setCurrentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: "Test"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Topics"),
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: "Archives"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: const Color.fromARGB(255, 100, 100, 100),
      ),
      floatingActionButton: [null, genFABArchivedPreset(false), genFABArchivedPreset(true), null][currentIndex],
    );
  }
}
