import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:badges/badges.dart' as base;
import 'package:flutter/services.dart';
import 'package:govdictionary/components/messanger.dart';
import 'package:govdictionary/components/theme_controller.dart';
import 'package:govdictionary/components/utils.dart';
import 'package:govdictionary/models/word.dart';
import 'package:govdictionary/pages/about.dart';
import 'package:govdictionary/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  runApp(
    ChangeNotifierProvider<ThemeController>(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: themeController.currentTheme,
      home: const WordPage(),
    );
  }
}

class WordPage extends StatefulWidget {
  const WordPage({super.key});

  @override
  State<WordPage> createState() => WordPageState();
}

class WordPageState extends State<WordPage> {
  late List<Word> allWords;
  late List<Word> filteredWords = [];
  late String updateAtDateTime;
  bool isLoading = true; // Track loading state
  bool isSearchBarOpen = false;
  int? selectedItemIndex;
  TextEditingController searchController = TextEditingController();

  // connectivity
  List<ConnectivityResult> connectionStatus = [ConnectivityResult.none];
  final Connectivity connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;

  @override
  void initState() {
    super.initState();
    loadWords();
    initConnectivity();
    connectivitySubscription =
        connectivity.onConnectivityChanged.listen(updateConnectionStatus);
  }

  //dispose
  @override
  void dispose() {
    connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      debugPrint('Couldn\'t check connectivity $e');
      return;
    }
    if (!mounted) return;
    updateConnectionStatus(result);
  }

  //updateConnectionStatus connectionStatus
  Future<void> updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      connectionStatus = result;
    });
    // debugPrint('Connectivity changed: $connectionStatus');
  }

//checkConnectionStatus
  checkConnectionStatus(List<dynamic> connectionStatusList) {
    return connectionStatusList.map(
      (connection) {
        return connection.toString() == 'ConnectivityResult.none'
            ? false
            : true;
      },
    ).join(',');
  }

//loadWords
  Future<void> loadWords() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$appDatabaseName');
      if (await file.exists()) {
        // If the file exists locally, load data from it
        final localJsonString = await file.readAsString();
        final List<dynamic> localJsonData = jsonDecode(localJsonString);
        setState(() {
          allWords =
              localJsonData.map((wordJson) => Word.fromJson(wordJson)).toList();
          filteredWords = allWords;
          isLoading = false;
          // debugPrint('${directory.path}/$appDatabaseName');
        });
      } else {
        // load from remoteFile
        final remoteFileResponse = await remoteFile;
        if (remoteFileResponse.statusCode == 200) {
          final remoteJsonString = remoteFileResponse.body;
          final List<dynamic> remoteJsonData = jsonDecode(remoteJsonString);
          await File('${directory.path}/$appDatabaseName')
              .writeAsString(remoteJsonString);
          setState(() {
            allWords = remoteJsonData
                .map((wordJson) => Word.fromJson(wordJson))
                .toList();
            filteredWords = allWords;
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load words');
        }
      }
    } catch (e) {
      debugPrint('Error loading JSON: $e');
      // Handle error appropriately
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchWords(String query) {
    setState(() {
      filteredWords = allWords
          .where((word) =>
              word.correct.toLowerCase().contains(query.toLowerCase()) ||
              word.incorrect.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget withSearchBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: searchWords,
            controller: searchController,
            autofocus: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {
                  searchController.clear();
                  searchWords('');
                },
                icon: const Icon(Icons.clear),
              ),
              labelText: 'Search-খুঁজুন',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Loading',
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: ListView.builder(
                        itemCount: filteredWords.length,
                        itemBuilder: (context, index) {
                          final word = filteredWords[index];
                          return ListTile(
                            selectedTileColor: Colors.deepPurple.shade50,
                            selected: index == selectedItemIndex,
                            title: Text(
                              '${word.correct} - ${word.incorrect}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal),
                            ),
                            leading: CircleAvatar(
                              child: Text(word.correct[0]),
                            ),
                            onTap: () {
                              // debugPrint(checkConnectionStatus(connectionStatus));
                              showDialogMessage(context, word);
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      width: 45,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.teal.shade100, Colors.teal.shade50],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: 50,
                        itemBuilder: (context, index) {
                          final letter = index < 11
                              ? [
                                  'অ',
                                  'আ',
                                  'ই',
                                  'ঈ',
                                  'উ',
                                  'ঊ',
                                  'ঋ',
                                  'এ',
                                  'ঐ',
                                  'ও',
                                  'ঔ',
                                ][index]
                              : [
                                  'ক',
                                  'খ',
                                  'গ',
                                  'ঘ',
                                  'ঙ',
                                  'চ',
                                  'ছ',
                                  'জ',
                                  'ঝ',
                                  'ঞ',
                                  'ট',
                                  'ঠ',
                                  'ড',
                                  'ঢ',
                                  'ণ',
                                  'ত',
                                  'থ',
                                  'দ',
                                  'ধ',
                                  'ন',
                                  'প',
                                  'ফ',
                                  'ব',
                                  'ভ',
                                  'ম',
                                  'য',
                                  'র',
                                  'ল',
                                  'শ',
                                  'ষ',
                                  'স',
                                  'হ',
                                  'ড়',
                                  'ঢ়',
                                  'য়',
                                  'ৎ',
                                  'ং',
                                  'ঃ',
                                  'ঁ'
                                ][index - 11];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                final query = letter;
                                searchController.text = query;
                                searchWords(query);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 32,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: searchController.text == letter
                                      ? Colors.teal.withAlpha(51)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    letter,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.teal.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget withOutSearchBar() {
    return Column(
      children: [
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Loading',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    if (updateAvailable()) {
                      await saveUpdate();
                      await loadWords();
                    }
                  },
                  child: ListView.builder(
                    itemCount: filteredWords.length,
                    itemBuilder: (context, index) {
                      final word = filteredWords[index];
                      return ListTile(
                        selectedTileColor: Colors.deepPurple.shade50,
                        selected: index == selectedItemIndex,
                        title: Text(
                          '${word.correct} - ${word.incorrect}',
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                        leading: CircleAvatar(
                          child: Text(
                              word.correct.isNotEmpty ? word.correct[0] : '?'),
                        ),
                        onTap: () {
                          showDialogMessage(context, word);
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  final List notifications = ['hello'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appName,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<ThemeController>(context, listen: false)
                  .toggleTheme();
            },
            icon: Icon(
              Provider.of<ThemeController>(context).isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(right: 10),
          //   child: base.Badge(
          //     // badgeAnimation: BadgeAnimation.slide(),
          //     badgeStyle: const base.BadgeStyle(badgeColor: Colors.amber),
          //     badgeContent: const Text('1'),
          //     child: const Icon(Icons.notifications),
          //     onTap: () {
          //       showDialog(
          //         context: context,
          //         builder: (BuildContext context) => AlertDialog(
          //           backgroundColor: Colors.grey.shade50,
          //           scrollable: true,
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //           content: SingleChildScrollView(
          //             child: ListBody(
          //               children: List.generate(
          //                 30,
          //                 (index) {
          //                   return ListTile(
          //                     onTap: () {
          //                       Navigator.pop(context);
          //                     },
          //                     leading: const IconButton(
          //                         onPressed: null,
          //                         icon: Icon(Icons.notifications)),
          //                     title: Text('Notification ${index + 1}'),
          //                   );
          //                 },
          //               ),
          //             ),
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
          IconButton(
            onPressed: () {
              setState(() {
                isSearchBarOpen = !isSearchBarOpen;
              });
            },
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.teal,
              ),
              child: Text(
                appName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AboutPage(
                      networkConnectionStatus:
                          checkConnectionStatus(connectionStatus),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Updated at'),
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                final stats = await fileStats();
                if (!mounted) return;
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Last Update'),
                    content: Text('${stats["UpdatedAt"]}'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: isSearchBarOpen
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: withSearchBar(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: withOutSearchBar(),
            ),
    );
  }
}
