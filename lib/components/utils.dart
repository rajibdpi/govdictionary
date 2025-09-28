import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:govdictionary/components/message_bus.dart';

//lastUpdateLocalFile()
String appName = 'সরকারি কাজে ব্যবহারিক বাংলা';
String appDatabaseName = 'words.json';
int localFileSize = 0;
int remotefileSize = 0;
int numberOfEntries = 0;
int numberOfKeys = 0;
String url =
    'https://raw.githubusercontent.com/rajibdpi/govdictionary/main/assets/words.json';
final remoteFile = http.get(Uri.parse(url));

// fileStats()
Future<Map> fileStats() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$appDatabaseName');
  final localFileStat = await file.stat();
  localFileSize = localFileStat.size;
  final remoteFileResponse = await remoteFile;
  remotefileSize = remoteFileResponse.bodyBytes.length;
  DateTime localUpdatedDateTime = localFileStat.modified;
  String updatedAt = localUpdatedDateTime.toString();
  return {
    'Last Updated': updatedAt,
    'Local File Size': _formatSize(localFileSize),
    'Remote File Size': _formatSize(remotefileSize)
  };
}

// checkUpdate
bool updateAvailable() {
  return localFileSize != remotefileSize;
}

// Helper function to format file sizes
String _formatSize(int bytes) {
  switch (bytes) {
    case < 1024:
      return '$bytes B';
    case < 1024 * 1024:
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    case < 1024 * 1024 * 1024:
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    case < 1024 * 1024 * 1024 * 1024:
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    default:
      return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(2)} TB';
  }
}

// saveUpdate
Future<void> saveUpdate() async {
  final directory = await getApplicationDocumentsDirectory();
  final remoteFileResponse = await remoteFile;
  if (remoteFileResponse.statusCode == 200) {
    final remoteJsonString = remoteFileResponse.body;
    await File('${directory.path}/$appDatabaseName')
        .writeAsString(remoteJsonString);
    // Reset the file sizes to trigger UI update
    localFileSize = 0;
    remotefileSize = 0;
    // Force reload app data
    await fileStats();
    // Notify all pages to refresh their data
    MessageBus().notifyUpdate();
  } else {
    throw Exception('Failed to load words');
  }
}
