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
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: themeController
          .updatedTheme, // Use updatedTheme for dynamic font size
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
  bool isLoading = true;
  bool isLoadingMore = false;
  bool isSearchBarOpen = true;
  int? selectedItemIndex;
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  static const int _itemsPerPage = 50;

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

  @override
  void dispose() {
    connectivitySubscription.cancel();
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      debugPrint('Couldn\'t check connectivity: $e');
      return;
    }
    if (!mounted) return;
    updateConnectionStatus(result);
  }

  Future<void> updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      connectionStatus = result;
    });
  }

  String checkConnectionStatus(List<dynamic> connectionStatusList) {
    return connectionStatusList
        .map((connection) => connection.toString() == 'ConnectivityResult.none'
            ? 'false'
            : 'true')
        .join(',');
  }

  Future<void> loadWords() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$appDatabaseName');
      if (await file.exists()) {
        final localJsonString = await file.readAsString();
        final List<dynamic> localJsonData = jsonDecode(localJsonString);
        setState(() {
          allWords =
              localJsonData.map((wordJson) => Word.fromJson(wordJson)).toList();
          originalWords = List.from(allWords);
          _loadMoreItems(true);
          isLoading = false;
        });
      } else {
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
              prefixIcon: Icon(Icons.search,
                  color:
                      Theme.of(context).inputDecorationTheme.prefixIconColor),
              suffixIcon: IconButton(
                onPressed: () {
                  searchController.clear();
                  searchWords('');
                },
                icon: Icon(Icons.clear,
                    color:
                        Theme.of(context).inputDecorationTheme.prefixIconColor),
              ),
              labelText: 'শব্দ খুঁজুন',
              border: Theme.of(context).inputDecorationTheme.border,
              enabledBorder:
                  Theme.of(context).inputDecorationTheme.enabledBorder,
              focusedBorder:
                  Theme.of(context).inputDecorationTheme.focusedBorder,
              labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
            ),
          ),
        ),
        Expanded(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
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
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            );
                          }
                          final word = filteredWords[index];
                          return ListTile(
                            selectedTileColor: Theme.of(context)
                                .listTileTheme
                                .selectedTileColor,
                            selected: index == selectedItemIndex,
                            title: Text(
                              'সঠিক - ${word.correct}\nভুল - ${word.incorrect}',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: Provider.of<ThemeController>(context)
                                    .fontSize,
                              ),
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              child: Text(
                                word.correct[0],
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  fontSize:
                                      Provider.of<ThemeController>(context)
                                              .fontSize -
                                          2,
                                ),
                              ),
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
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 100),
                            Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 10)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(25),
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
                                      ? Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withAlpha(51)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    letter,
                                    style: TextStyle(
                                      fontSize:
                                          Provider.of<ThemeController>(context)
                                              .fontSize,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
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
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
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
                        selectedTileColor:
                            Theme.of(context).listTileTheme.selectedTileColor,
                        selected: index == selectedItemIndex,
                        title: Text(
                          'সঠিক - ${word.correct}\nভুল - ${word.incorrect}',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize:
                                Provider.of<ThemeController>(context).fontSize,
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          child: Text(
                            word.correct[0],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontSize: Provider.of<ThemeController>(context)
                                      .fontSize -
                                  2,
                            ),
                          ),
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
          style: TextStyle(
            fontSize: Provider.of<ThemeController>(context).fontSize,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
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
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isSearchBarOpen = !isSearchBarOpen;
              });
            },
            icon: Icon(
              Icons.search,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                appName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: Provider.of<ThemeController>(context).fontSize,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.info,
                color: Theme.of(context).listTileTheme.iconColor,
              ),
              title: Text(
                'About',
                style: TextStyle(
                  color: Theme.of(context).listTileTheme.textColor,
                  fontSize: Provider.of<ThemeController>(context).fontSize,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
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
              leading: Icon(
                Icons.settings,
                color: Theme.of(context).listTileTheme.iconColor,
              ),
              title: Text(
                'Settings',
                style: TextStyle(
                  color: Theme.of(context).listTileTheme.textColor,
                  fontSize: Provider.of<ThemeController>(context).fontSize,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                if (!mounted) return;
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.update,
                color: Theme.of(context).listTileTheme.iconColor,
              ),
              title: Text(
                'Check for Update',
                style: TextStyle(
                  color: Theme.of(context).listTileTheme.textColor,
                  fontSize: Provider.of<ThemeController>(context).fontSize,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                if (!mounted) return;
                final stats = await fileStats();
                if (!mounted) return;
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) => AlertDialog(
                      title: Text(
                        'Last Update',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize:
                              Provider.of<ThemeController>(context).fontSize,
                        ),
                      ),
                      content: Text(
                        '${stats["UpdatedAt"]}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize:
                              Provider.of<ThemeController>(context).fontSize -
                                  2,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: Provider.of<ThemeController>(context)
                                  .fontSize,
                            ),
                          ),
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
