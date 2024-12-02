import 'package:flutter/material.dart';
import 'package:yafca/database.dart';
import 'package:yafca/utils.dart';


class SubjectList extends StatefulWidget {
  final bool archived;
  
  const SubjectList(this.archived, {super.key});

  @override
  State<SubjectList> createState() => _SubjectListState();
}

class _SubjectListState extends State<SubjectList> {
  bool isLoading = true;
  List<String> subjects = [];
  List<List<Question>?> subjectQuestions = [];

  @override
  void initState() {
    super.initState();
    doInitStuff();
  }

  Future<void> doInitStuff() async {
    await fetchSubjects();
    setState(() {
      isLoading = false;
    });
    await fetchQuestions();
  }

  Future<void> fetchSubjects() async {
    Set<String> fetchedSubjects = await (widget.archived ? getArchivedSubjects() : getActiveSubjects());
    subjectQuestions = List.filled(fetchedSubjects.length, null);
    subjects = fetchedSubjects.toList();
  }

  Future<void> fetchQuestions() async {
    for (int i = 0; i < subjects.length; i++) {
      List<Question> value = await getSubjectQuestions(subjects[i], widget.archived);
      setState(() {
        subjectQuestions[i] = value;
      });
    }
  }

  Widget subjectCardBuilder(BuildContext context, int i) {
    final subject = subjects[i];
    double? ratio;
    if (subjectQuestions[i] != null) {
      int successCount = 0;
      int totalCount = 0;
      for (Question question in subjectQuestions[i]!) {
        for (var v in question.history) {
          if (v) {
            successCount++;
          }
          totalCount++;
        }
      }
      if (totalCount > 0) {
        ratio = successCount / totalCount;
      }
    }
    return Card(
      child: ListTile(
        title: Text(subject),
        trailing: ratio == null ? null : Text("$ratio%"),
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 12, bottom: 5),
                      child: Text(
                        subject,
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
                              title: const Text("Are you sure ?"),
                              content: Text("You are about to completely delete the ${widget.archived ? 'archived' : 'unarchived'} subject $subject."
                                  "This action is not reversible"),
                              actions: [
                                TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("Cancel")),
                                TextButton(onPressed: () {
                                  Navigator.of(context).pop();
                                  Future<void> delete_future = deleteSubject(widget.archived, subject);
                                  showSnackBar(context, Text("Subject $subject has been removed."));
                                  Navigator.of(context).pop();
                                  delete_future.then((_) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    doInitStuff();
                                  });
                                }, child: Text("Delete '$subject'", style: TextStyle(color: Colors.red))),
                              ],
                            );
                          }
                        );
                      },
                      child: Text(
                        "Delete All Subject",
                        style: TextStyle(color: Colors.red)
                      )
                    ),
                    TextButton(
                      onPressed: null,
                      child: Text(widget.archived ? "Unarchive" : "Archive")
                    ),
                  ],
                ),
              );
            },
          );
        },
        onTap: () {
          showSnackBar(context, Text("Sorry Unimplemented Yet"));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Loading..."), CircularProgressIndicator()]))
      : ListView.builder(
      itemCount: subjects.length,
      itemBuilder: subjectCardBuilder,
    );
  }
}
