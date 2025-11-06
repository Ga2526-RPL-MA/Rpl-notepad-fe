import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/view/class_discussion_page.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/view/discussion_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RPL Notepad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DiscussionPage(),
    );
  }
}
