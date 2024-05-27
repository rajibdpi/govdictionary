import 'package:flutter/material.dart';
import 'package:govdictionary/models/word.dart';

class WordDetails extends StatefulWidget {
  final Word word;
  // final String incorrect;
  const WordDetails({super.key, required this.word});

  @override
  State<WordDetails> createState() => _WordDetailsState();
}

class _WordDetailsState extends State<WordDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            onPressed: () {
              print("Share Button Pressed");
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {
              print("Copy Button Pressed");
            },
            icon: const Icon(Icons.copy),
          ),
        ],
        title: const Text('সরকারি কাজে ব্যবহারিক বাংলা'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'শুদ্ধ-${widget.word.correct}',
              style: const TextStyle(color: Colors.green),
            ),
            Text(
              'অশুদ্ধ/বর্জনীয়-${widget.word.incorrect}',
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
