import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

//lastUpdateLocalFile() // Get metadata of the local file

String appDatabaseName = 'words.json';

String? localFileS;
String? onLineFileSize;
int fileSize = 0;
int numberOfEntries = 0;
int numberOfKeys = 0;
Future<String> lastUpdatedLocalFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$appDatabaseName');
  final localFileStat = await file.stat();
  localFileS = localFileStat.size.toString();
  // final datafile = await http.get(Uri.parse(
  //     'https://api.github.com/repos/rajibdpi/govdictionary/contents/assets/words.json'));
  // onLineFileSize = datafile.headers['size'];
  // print("onLineFileSize:$onLineFileSize");
  print("localFileS:$localFileS");

// lastUpdatedOnlineFile()
  const owner = 'rajibdpi';
  const repo = 'govdictionary';
  const filePath = 'assets/words.json';
  const fileUrl =
      'https://cdn.jsdelivr.net/gh/rajibdpi/govdictionary@main/assets/words.json';
  // const fileUrl ='https://api.github.com/repos/$owner/$repo/contents/$filePath';
  final response = await http.get(Uri.parse(fileUrl));
  final jsonData = jsonDecode(response.body);
  fileSize = response.bodyBytes.length;
  print('fileSize:$fileSize');
  numberOfEntries = jsonData.length;
  print('numberOfEntries:$numberOfEntries');

  // numberOfKeys = jsonData.fold(0, (sum, item) => sum + item.keys.length);

  // onLineFileSize = (onlineData as Map)['size'].toString();
  // print("OnlineFileS:$onLineFileSize");
  DateTime localUpdatedDateTime = localFileStat.modified;
  String updatedAt = localUpdatedDateTime.toString();
  return updatedAt;
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
