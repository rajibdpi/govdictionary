import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:govdictionary/components/messanger.dart';
import 'package:govdictionary/components/utils.dart';
import 'package:govdictionary/models/word.dart';
import 'package:govdictionary/pages/about.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const WordPage(),
    );
  }
}

class WordPage extends StatefulWidget {
  const WordPage({Key? key}) : super(key: key);

  @override
  _WordPageState createState() => _WordPageState();
}

class _WordPageState extends State<WordPage> {
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
      print('Couldn\'t check connectivity $e');
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    // print(result);
    return updateConnectionStatus(result);
  }

  //updateConnectionStatus connectionStatus
  Future<void> updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      connectionStatus = result;
    });
    // print('Connectivity changed: $connectionStatus');
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
        // If the file doesn't exist, fetch data from the network and save it locally
      }
    } catch (e) {
      print('Error loading JSON: $e');
      // Handle error
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
              : ListView.builder(
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
                        child: Text(word.correct[0]),
                      ),
                      onTap: () {
                        print(checkConnectionStatus(connectionStatus));
                        showDialogMessage(context, word);
                      },
                    );
                  },
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
              : ListView.builder(
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
                        child: Text(word.correct[0]),
                      ),
                      onTap: () {
                        print(checkConnectionStatus(connectionStatus));
                        showDialogMessage(context, word);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          appName,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        // leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        actions: [
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
        backgroundColor: Colors.indigo,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.indigo,
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AboutPage(
                          networkConnectionStatus:
                              checkConnectionStatus(connectionStatus),
                        )));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Updated at'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to settings page or perform settings related actions
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
// ListTile(
            //   leading: const Icon(Icons.update),
            //   title: FutureBuilder<List<Map>>(
            //     future: lastUpdatedLocalFile(),
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return const CircularProgressIndicator(
            //           semanticsLabel: 'Loading..',
            //         );
            //       } else if (snapshot.hasError) {
            //         return Text('Error: ${snapshot.error}');
            //       } else {
            //         return Text(
            //           'Updated at: ${snapshot.data!}',
            //           style: const TextStyle(fontSize: 10),
            //         );
            //       }
            //     },
            //   ),
            //   onTap: () {
            //     Navigator.pop(context); // Close the drawer
            //   },
            // ),