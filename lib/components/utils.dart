import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:govdictionary/components/messanger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

//lastUpdateLocalFile()
String appDatabaseName = 'words.json';
int localFileSize = 0;
int remotefileSize = 0;
int numberOfEntries = 0;
int numberOfKeys = 0;
String url =
    'https://raw.githubusercontent.com/rajibdpi/govdictionary/latest/assets/words.json';
final remoteFile = http.get(Uri.parse(url));

// fileStats()
Future<List<Map>> fileStats() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$appDatabaseName');
  final localFileStat = await file.stat();
  localFileSize = localFileStat.size;
  final remoteFileResponse = await remoteFile;
  remotefileSize = remoteFileResponse.bodyBytes.length;
  DateTime localUpdatedDateTime = localFileStat.modified;
  String updatedAt = localUpdatedDateTime.toString();
  return [
    {
      'updatedAt': updatedAt,
      'localFileSize': localFileSize,
      'remotefileSize': remotefileSize
    }
  ];
}

// checkUpdate
bool updateAvailable() {
  return localFileSize < remotefileSize ? true : false;
}

// saveUpdate
Future<void> saveUpdate() async {
  final directory = await getApplicationDocumentsDirectory();
  final remoteFileResponse = await remoteFile;
  if (remoteFileResponse.statusCode == 200) {
    final remoteFileJsonString = remoteFileResponse.body;
    final remoteFileSaved = await File('${directory.path}/$appDatabaseName')
        .writeAsString(remoteFileJsonString);
    AlertDialog(
      content: Text('$remoteFileSaved'),
    );
  } else {
    throw Exception('Failed to load words');
  }
  // final List<dynamic> jsonData = jsonDecode(remoteFileJsonString);
  // setState(() {
  //   allWords = jsonData.map((wordJson) => Word.fromJson(wordJson)).toList();
  //   filteredWords = allWords;
  //   isLoading = false;
  // });
  // Save JSON data locally with a custom file name
}
