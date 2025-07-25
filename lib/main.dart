import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
  bool isLoadingMore = false; // Track pagination loading state
  bool isSearchBarOpen = true;
  int? selectedItemIndex;
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  static const int _itemsPerPage = 50;

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
    _scrollController.addListener(_onScroll);
  }

  //dispose
  @override
  void dispose() {
    connectivitySubscription.cancel();
    _scrollController.dispose();
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
          originalWords = List.from(allWords);
          _loadMoreItems(true);
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
            originalWords = List.from(allWords);
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

  late List<Word> originalWords;

  void searchWords(String query) {
    setState(() {
      if (query.isEmpty) {
        allWords = List.from(originalWords);
      } else {
        allWords = originalWords
            .where((word) =>
                word.correct.isNotEmpty &&
                word.correct.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
      }
      _currentPage = 0;
      _loadMoreItems(true);
    });
  }

  void _loadMoreItems(bool reset) {
    if (reset) {
      filteredWords = [];
      _currentPage = 0;
    }

    if (allWords.isEmpty) {
      setState(() {
        isLoadingMore = false;
      });
      return;
    }

    final int startIndex = _currentPage * _itemsPerPage;
    if (startIndex >= allWords.length) {
      setState(() {
        isLoadingMore = false;
      });
      return;
    }

    final int endIndex = (startIndex + _itemsPerPage <= allWords.length)
        ? startIndex + _itemsPerPage
        : allWords.length;

    setState(() {
      filteredWords.addAll(allWords.sublist(startIndex, endIndex));
      _currentPage++;
      isLoadingMore = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !isLoadingMore) {
      setState(() {
        isLoadingMore = true;
      });
      _loadMoreItems(false);
    }
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
              labelText: 'শব্দ খুঁজুন',
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
                        controller: _scrollController,
                        itemCount:
                            filteredWords.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredWords.length && isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          }
                          final word = filteredWords[index];
                          return ListTile(
                            selectedTileColor: Colors.deepPurple.shade50,
                            selected: index == selectedItemIndex,
                            title: Row(
                              children: [
                                Text(
                                  'সঠিক - ${word.correct}\nভুল - ${word.incorrect}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                                // const Text(' - '),
                                // Text(
                                //   word.incorrect,
                                //   style: const TextStyle(
                                //     fontWeight: FontWeight.normal,
                                //     color: Colors.red,
                                //   ),
                                // ),
                              ],
                            ),
                            leading: CircleAvatar(
                              child: Text(word.correct[0]),
                            ),
                            onTap: () {
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
                                      ? const Color.fromARGB(255, 109, 114, 114)
                                          .withAlpha(51)
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
                        title: Row(
                          children: [
                            Text(
                              word.correct,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.green,
                              ),
                            ),
                            const Text(' - '),
                            Text(
                              word.incorrect,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.red,
                              ),
                            ),
                          ],
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
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                if (!mounted) return;
                await Navigator.of(context).push(
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
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                if (!mounted) return;
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Check for Update'),
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                if (!mounted) return;
                final stats = await fileStats();
                if (!mounted) return;
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) => AlertDialog(
                      title: const Text('Last Update'),
                      content: Text('${stats["UpdatedAt"]}'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
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
