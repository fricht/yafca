import 'package:flutter/material.dart';
import 'package:yafca/database.dart';
import 'package:yafca/test/take_test.dart';


class CreateTestPage extends StatefulWidget {
  const CreateTestPage({super.key});

  @override
  State<CreateTestPage> createState() => _CreateTestPageState();
}

class _CreateTestPageState extends State<CreateTestPage> {
  List<String> subjects = [];
  Set<int> selectedSubjects = {};
  bool canLaunch = false;
  bool isLoading = true;

  Future<void> fetchSubjects() async {
    Set<String> fetchedSubjects = await getActiveSubjects();
    setState(() {
      subjects = fetchedSubjects.toList();
      isLoading = false;
    });
    updateBtnState();
  }

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Widget subjectCardBuilder(BuildContext context, int index) {
    return Card(
      color: selectedSubjects.contains(index) ? Colors.green : null,
      child: ListTile(
        title: Text(subjects[index]),
        onTap: () {
          setState(() {
            if (selectedSubjects.contains(index)) {
              selectedSubjects.remove(index);
            } else {
              selectedSubjects.add(index);
            }
          });
          updateBtnState();
        },
      ),
    );
  }

  void launchTest() {
    List<String> filteredSubjects = [];
    for (int index in selectedSubjects) {
      filteredSubjects.add(subjects[index]);
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TakeTest(filteredSubjects))
    );
  }

  void updateBtnState() {
    setState(() {
      if (selectedSubjects.isEmpty || isLoading) {
        canLaunch = false;
      } else {
        canLaunch = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
            itemCount: subjects.length,
            itemBuilder: subjectCardBuilder,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5),
          height: 100,
          width: double.infinity,
          child: ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.green),
            ),
            onPressed: canLaunch ? launchTest : null,
            child: const Text("Start Test"),
          ),
        ),
      ],
    );
  }
}
