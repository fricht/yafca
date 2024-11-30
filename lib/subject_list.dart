import 'package:flutter/material.dart';
import 'package:yafca/database.dart';


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
    setState(() {});
  }

  Future<void> fetchSubjects() async {
    Set<String> fetchedSubjects = await (widget.archived ? getArchivedSubjects() : getActiveSubjects());
    subjectQuestions = List.filled(fetchedSubjects.length, null);
    subjects = fetchedSubjects.toList();
  }

  Future<void> fetchQuestions() async {
    for (int i = 0; i < subjects.length; i++) {
      subjectQuestions[i] = await getSubjectQuestions(subjects[i], widget.archived);
    }
  }

  Widget subjectCardBuilder(BuildContext context, int i) {
    final s = subjects[i];
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
        title: Text(s),
        trailing: ratio == null ? null : Text("$ratio%"),
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
