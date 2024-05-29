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

Future<List<Map>> lastUpdatedLocalFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$appDatabaseName');
  final localFileStat = await file.stat();
  localFileSize = localFileStat.size;
  // print("localFileSize:$localFileSize");
// lastUpdatedOnlineFile()
  const fileUrl =
      'https://raw.githubusercontent.com/rajibdpi/govdictionary/latest/assets/words.json';
  final response = await http.get(Uri.parse(fileUrl));
  onlinefileSize = response.bodyBytes.length;
  // print('OnlineFileSize:$onlinefileSize');
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
    Uri.parse(
        'https://raw.githubusercontent.com/rajibdpi/govdictionary/latest/assets/words.json'),
  );
  if (response.statusCode == 200) {
    final jsonString = response.body;
    // final List<dynamic> jsonData = jsonDecode(jsonString);
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
    if (response.headers.containsKey('last-modified')) {
      final hDateTime = response.headers['last-modified'];
      return hDateTime.toString();
    } else {
      return 'Error: Missing or invalid file information: ${response.statusCode}';
    }
  } else {
    return 'Failed to fetch file information: ${response.statusCode}';
  }
}
