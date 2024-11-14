import 'package:flutter/material.dart';
import 'package:yafca/database.dart';


class TakeTest extends StatefulWidget {
  final List<String> subjects;

  const TakeTest(this.subjects, {super.key});

  @override
  State<TakeTest> createState() => _TakeTestState();
}

class _TakeTestState extends State<TakeTest> {
  bool isLoading = true;
  late final List<Question> questions;
  int currentQuestion = 0;

  void fetchQuestions() async {
    List<Question> allQuestions = [];
    for (String subject in widget.subjects) {
      allQuestions.addAll(await getSubjectQuestions(subject, false));
    }
    questions = allQuestions;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test"),
      ),
      body: isLoading
      ? const Center(child: Row(
        children: [
          Text("Loading questions..."),
          CircularProgressIndicator(),
        ],
      ))
      : Column(
        children: [Text("Working on it...")],
      ),
    );
  }
}
