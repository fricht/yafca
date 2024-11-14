import 'package:flutter/material.dart';
import 'package:yafca/database.dart';
import 'package:yafca/utils.dart';


class AddQuestion extends StatefulWidget {
  final bool archivedDefault;

  const AddQuestion(this.archivedDefault, {super.key});

  @override
  State<AddQuestion> createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  Set<String> subjects = {};

  final formKey = GlobalKey<FormState>();
  late TextEditingController subjectController;
  final questionController = TextEditingController();
  final answerController = TextEditingController();
  bool reversibleValue = false;
  late bool archivedValue = widget.archivedDefault;
  
  Future<void> fetchSubjects() async {
    Set<String> fetchedSubjects = await getAllSubjects();
    setState(() {
      subjects = fetchedSubjects;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }
  
  @override
  void dispose() {
    super.dispose();
    // subjectController is disposed by the autocomplete field
    questionController.dispose();
    answerController.dispose();
  }
  
  String? emptyValidator(String? txt) {
    if (txt == null || txt.trim().isEmpty) {
      return "Field required";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add question"),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(5),
              child: Autocomplete<String>(
                fieldViewBuilder: (BuildContext context, TextEditingController controller, FocusNode focusNode, void Function() onEditingComplete) {
                  subjectController = controller;
                  return TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Subject",
                      border: OutlineInputBorder(),
                    ),
                    validator: emptyValidator,
                    controller: controller,
                    focusNode: focusNode,
                    onEditingComplete: onEditingComplete,
                  );
                },
                optionsBuilder: (TextEditingValue input) => subjects.where((String item) => item.trim().toLowerCase().contains(input.text.trim().toLowerCase())),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(5),
              child: TextFormField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: "Question",
                  border: OutlineInputBorder(),
                ),
                validator: emptyValidator,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(5),
              child: TextFormField(
                controller: answerController,
                decoration: const InputDecoration(
                  labelText: "Answer",
                  border: OutlineInputBorder(),
                ),
                validator: emptyValidator,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(5),
              child: CheckboxListTile(
                title: Row(
                  children: [
                    const Text("Reversible"),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const AlertDialog(
                              content: Text("If the card is reversible, the question and the answer are randomly swapped when asked.\nUseful for vocabulary."),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                value: reversibleValue,
                onChanged: (bool? value) {
                  setState(() {
                    reversibleValue = value!;
                  });
                },
                tristate: false,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(5),
              child: CheckboxListTile(
                title: Row(
                  children: [
                    const Text("Archive"),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const AlertDialog(
                              content: Text("Archive the card when created."),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                value: archivedValue,
                onChanged: (bool? value) {
                  setState(() {
                    archivedValue = value!;
                  });
                },
                tristate: false,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              child: ElevatedButton(
                child: const Text("Ok"),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Question question = Question(
                      0,
                      subjectController.text.trim(),
                      questionController.text.trim(),
                      answerController.text.trim(),
                      reversibleValue,
                      0,
                      archivedValue,
                    );
                    addQuestion(question).then((_) {
                      showSnackBar(context, Text("${question.subject} question added"));
                      Navigator.of(context).pop();
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
