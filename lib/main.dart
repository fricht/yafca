import 'package:flutter/material.dart';
import 'package:yafca/app.dart';
import 'package:yafca/database.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initDatabase().then((value) => runApp(const AppEntry()));
}


class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainScreen(),
    );
  }
}
