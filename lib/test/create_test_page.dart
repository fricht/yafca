import 'package:flutter/material.dart';
import 'package:yafca/database.dart';
import 'package:yafca/utils.dart';


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
      child: ListTile(
        title: Text(subjects[index]),
        tileColor: selectedSubjects.contains(index) ? Colors.lightGreen : null,
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
    // todo : really launch test
    showSnackBar(context, Text("Sorry, not yet implemented"));
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
