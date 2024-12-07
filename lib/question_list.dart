import 'package:flutter/material.dart';
import 'package:yafca/database.dart';
import 'package:yafca/utils.dart';


class QuestionList extends StatefulWidget {
  final String subject;
  final bool archived;

  const QuestionList(this.subject, this.archived, {super.key});

  @override
  State<QuestionList> createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  bool isLoading = true;
  List<Question> questions = [];
  bool selectionMode = false;
  Set<int> selected = {};

  Future<void> doInitStuff() async {
    selectionMode = false;
    selected.clear();
    questions = await getSubjectQuestions(widget.subject, widget.archived);
    if (questions.isEmpty) {
      Navigator.of(context).pop();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    doInitStuff();
  }

  String obfuscateString(String str) {
    if (str.length > 3) {
      return "${str.substring(0, 3)}...";
    } else if (str.length > 1) {
      return "${str.substring(0, 1)}...";
    }
    return "...";
  }

  void handleSelection(int i) {
    setState(() {
      if (selected.contains(i)) {
        selected.remove(i);
      } else {
        selected.add(i);
      }
      if (selected.isEmpty) {
        selectionMode = false;
      } else {
        selectionMode = true;
      }
    });
  }

  Widget buildQuestionList(BuildContext context, int i) {
    Question question = questions[i];
    return Card(
      color: selected.contains(i) ? Colors.blue : null,
      child: ListTile(
        title: Text(question.reversible ? obfuscateString(question.question) : question.question),
        subtitle: Text(obfuscateString(question.answer)),
        onTap: selectionMode ? () {handleSelection(i);} : null,
        onLongPress: () {handleSelection(i);},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
        actions: selectionMode ? [IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                List<Widget> actions = [
                  Container(
                    padding: EdgeInsets.only(top: 12, bottom: 5),
                    child: Text(
                      "Actions",
                      style: TextStyle(
                          fontSize: 25
                      ),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Are you sure ?"),
                              content: Text("You are about to completely delete ${selected.length} question${selected.length > 1 ? 's' : ''}."
                                  "This action is not reversible"),
                              actions: [
                                TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("Cancel")),
                                TextButton(onPressed: () {
                                  Navigator.of(context).pop();
                                  List<int> ids = [];
                                  for (int i in selected) {
                                    ids.add(questions[i].id);
                                  }
                                  Future<void> deleteFuture = deleteQuestions(ids);
                                  setState(() {
                                    isLoading = true;
                                  });
                                  showSnackBar(context, Text("${selected.length} question${selected.length > 1 ? 's' : ''} has been removed."));
                                  Navigator.of(context).pop();
                                  deleteFuture.then((_) {
                                    doInitStuff();
                                  });
                                }, child: Text("Delete ${selected.length} question${selected.length > 1 ? 's' : ''}", style: TextStyle(color: Colors.red))),
                              ],
                            );
                          }
                        );
                      },
                      child: Text(
                          "Delete",
                          style: TextStyle(color: Colors.red)
                      )
                  ),
                  TextButton(
                      onPressed: () {
                        List<int> ids = [];
                        for (int i in selected) {
                          ids.add(questions[i].id);
                        }
                        Future<void> archiveFuture = setQuestionsArchiveState(!widget.archived, ids);
                        setState(() {
                          isLoading = true;
                        });
                        showSnackBar(context, Text("${selected.length} question${selected.length > 1 ? 's' : ''} has been ${widget.archived ? 'unarchived' : 'archived'}."));
                        Navigator.of(context).pop();
                        archiveFuture.then((_) {
                          doInitStuff();
                        });
                      },
                      child: Text(widget.archived ? "Unarchive" : "Archive")
                  ),
                ];
                if (selected.length == 1) {
                  actions.add(TextButton(
                      onPressed: null,
                      child: Text("Edit")
                  ));
                }
                return SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: actions,
                  ),
                );
              },
            );
          },
        )] : null,
      ),
      body: isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
        itemCount: questions.length,
        itemBuilder: buildQuestionList,
      ),
    );
  }
}
