import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

//lastUpdateLocalFile()
String appDatabaseName = 'words.json';
int localFileSize = 0;
int onlinefileSize = 0;
int numberOfEntries = 0;
int numberOfKeys = 0;
String remoteFileUrl =
    'https://raw.githubusercontent.com/rajibdpi/govdictionary/latest/assets/words.json';

Future<List<Map>> lastUpdatedLocalFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$appDatabaseName');
  final localFileStat = await file.stat();
  localFileSize = localFileStat.size;

  // lastUpdatedOnlineFile()
  final response = await http.get(Uri.parse(remoteFileUrl));
  onlinefileSize = response.bodyBytes.length;
  DateTime localUpdatedDateTime = localFileStat.modified;
  String updatedAt = localUpdatedDateTime.toString();
  return [
    {
      'updatedAt': updatedAt,
      'localFileSize': localFileSize,
      'onlinefileSize': onlinefileSize
    }
  ];
}

// checkUpdate
bool updateAvailable() {
  return localFileSize < onlinefileSize ? true : false;
}

// saveUpdate
Future<void> saveUpdate() async {
  final directory = await getApplicationDocumentsDirectory();
  final response = await http.get(
    Uri.parse(remoteFileUrl),
  );
  if (response.statusCode == 200) {
    final jsonString = response.body;
    await File('${directory.path}/words.json').writeAsString(jsonString);
    // print(jsonString);
  } else {
    throw Exception('Failed to load words');
  }

  // final List<dynamic> jsonData = jsonDecode(jsonString);
  // setState(() {
  //   allWords = jsonData.map((wordJson) => Word.fromJson(wordJson)).toList();
  //   filteredWords = allWords;
  //   isLoading = false;
  // });
  // Save JSON data locally with a custom file name
}
