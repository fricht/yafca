import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yafca/database.dart';
import 'package:yafca/utils.dart';


class TakeTest extends StatefulWidget {
  final List<String> subjects;

  const TakeTest(this.subjects, {super.key});

  @override
  State<TakeTest> createState() => _TakeTestState();
}

class _TakeTestState extends State<TakeTest> {
  bool isLoading = true;
  List<Question>? questions;
  List<bool> swaps = [];
  int currentQuestion = 0;

  bool? isCorrect;
  bool revealed = false;

  void fetchQuestions() async {
    List<Question> allQuestions = [];
    for (String subject in widget.subjects) {
      allQuestions.addAll(await getSubjectQuestions(subject, false));
    }
    questions = allQuestions;
    for (Question _ in allQuestions) {
      swaps.add(Random().nextBool());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  void handleValidation(bool success) {
    showSnackBar(context, const Text("TODO : register successness")); // TODO : register successness
    if (currentQuestion == questions!.length - 1) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        isCorrect = null;
        revealed = false;
        currentQuestion++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Test"),
        ),
        body: const Center(child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Loading questions..."),
            CircularProgressIndicator(),
          ],
        )),
      );
    }
    String question = questions![currentQuestion].question;
    String answer = questions![currentQuestion].answer;
    if (questions![currentQuestion].reversible && swaps[currentQuestion]) {
      // swap question & answer
      String t = question;
      question = answer;
      answer = t;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Test - ${questions![currentQuestion].subject}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(5),
              width: double.infinity,
              child: Card(
                child: Center(child: Text(question)),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(5),
              width: double.infinity,
              child: GestureDetector(
                onTap: revealed ? null : () {
                  setState(() {
                    revealed = true;
                  });
                },
                child: Card(
                  child: Center(child: Text(revealed ? answer : "(Tap to reveal)")),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: double.infinity,
                    padding: const EdgeInsets.all(5),
                    child: ElevatedButton(
                      onPressed: revealed ?
                        () {
                          if (isCorrect == false) {
                            handleValidation(false);
                          } else {
                            setState(() {
                              isCorrect = false;
                            });
                          }
                        } : null,
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.red),
                      ),
                      child: Center(child: Text(isCorrect == false ? "Wrong\n(Tap again to confirm)" : "Wrong")),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: double.infinity,
                    padding: const EdgeInsets.all(5),
                    child: ElevatedButton(
                      onPressed: revealed ?
                        () {
                          if (isCorrect == true) {
                            handleValidation(true);
                          } else {
                            setState(() {
                              isCorrect = true;
                            });
                          }
                        } : null,
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.green),
                      ),
                      child: Center(child: Text(isCorrect == true ? "Right\n(Tap again to confirm)" : "Right")),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
