import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

//lastUpdateLocalFile() // Get metadata of the local file

String appDatabaseName = 'words.json';
int localFileSize = 0;
int onlinefileSize = 0;
int numberOfEntries = 0;
int numberOfKeys = 0;

Future<List<Map>> lastUpdatedLocalFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$appDatabaseName');
  final localFileStat = await file.stat();
  localFileSize = localFileStat.size;
  print("localFileSize:$localFileSize");

// lastUpdatedOnlineFile()
  const fileUrl =
      'https://raw.githubusercontent.com/rajibdpi/govdictionary/latest/assets/words.json';
  final response = await http.get(Uri.parse(fileUrl));
  onlinefileSize = response.bodyBytes.length;
  print('OnlineFileSize:$onlinefileSize');
  DateTime localUpdatedDateTime = localFileStat.modified;
  String updatedAt = localUpdatedDateTime.toString();
  // return updatedAt;
  return [
    {
      'updatedAt': updatedAt,
      'localFileSize': localFileSize,
      'onlinefileSize': onlinefileSize
    }
  ];

  // const owner = 'rajibdpi';
  // const repo = 'govdictionary';
  // const filePath = 'assets/words.json';
  // 'https://raw.githubusercontent.com/rajibdpi/govdictionary/main/assets/words.json';
  // 'https://cdn.jsdelivr.net/gh/rajibdpi/govdictionary@main/assets/words.json';
  // const fileUrl ='https://api.github.com/repos/$owner/$repo/contents/$filePath';
  // numberOfEntries = jsonData.length;
  // print('numberOfEntries:$numberOfEntries');
  // numberOfKeys = jsonData.fold(0, (sum, item) => sum + item.keys.length);
  // onLineFileSize = (onlineData as Map)['size'].toString();
  // print("OnlineFileS:$onLineFileSize");
}

// checkUpdate
bool updateAvailable() {
  return localFileSize < onlinefileSize ? true : false;
}

Future<void> saveUpdate() async {
  final directory = await getApplicationDocumentsDirectory();

  final response = await http.get(
    Uri.parse(
        'https://raw.githubusercontent.com/rajibdpi/govdictionary/latest/assets/words.json'),
  );
  if (response.statusCode == 200) {
    final jsonString = response.body;
    final List<dynamic> jsonData = jsonDecode(jsonString);
    // setState(() {
    //   allWords = jsonData.map((wordJson) => Word.fromJson(wordJson)).toList();
    //   filteredWords = allWords;
    //   isLoading = false;
    // });
    // Save JSON data locally with a custom file name
    await File('${directory.path}/words.json').writeAsString(jsonString);
    // print(jsonString);
  } else {
    throw Exception('Failed to load words');
  }
}

Future<String> lastUpdatedOnlineFile() async {
  const owner = 'rajibdpi';
  const repo = 'govdictionary';
  const filePath = 'assets/words.json';
  final response = await http.get(Uri.parse(
      'https://api.github.com/repos/$owner/$repo/contents/$filePath'));
  if (response.statusCode == 200 &&
      response.headers.containsKey('last_modified')) {
    // final Map<String, dynamic>? fileInfo = jsonDecode(response.body);
    // final Map<String, dynamic>? headerInfo = jsonDecode(response.body);
    if (response.headers.containsKey('last-modified')) {
      final hDateTime = response.headers['last-modified'];
      // Convert lastModifiedStr to DateTime
      return hDateTime.toString();
    } else {
      // print('Error: Missing or invalid file information.');
      return 'Error: Missing or invalid file information: ${response.statusCode}';
    }
  } else {
    // Handle HTTP error
    // print('Failed to fetch file information: ${response.statusCode}');
    return 'Failed to fetch file information: ${response.statusCode}';
  }
}
