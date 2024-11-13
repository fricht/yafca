import 'package:flutter/material.dart';
import 'package:yafca/database.dart';


class SubjectList extends StatefulWidget {
  final bool archived;
  
  const SubjectList(this.archived, {super.key});

  @override
  State<SubjectList> createState() => _SubjectListState();
}

class _SubjectListState extends State<SubjectList> {
  List<String> subjects = ["Loading ..."];

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    List<String> fetchedSubjects = await (widget.archived ? getArchivedSubjects() : getActiveSubjects());
    setState(() {
      subjects = fetchedSubjects;
    });
  }

  Widget subjectCardBuilder(BuildContext context, int i) {
    final s = subjects[i];
    return Card(
      child: ListTile(
        title: Text(s),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: subjects.length,
      itemBuilder: subjectCardBuilder,
    );
  }
}
