import 'dart:convert';
import 'dart:io';
import 'package:govdictionary/components/messanger.dart';
import 'package:govdictionary/components/utils.dart';
import 'package:govdictionary/models/word.dart';
import 'package:govdictionary/pages/about.dart';
import 'package:flutter/material.dart';
// import 'package:govdictionary/pages/detail.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'সরকারি কাজে ব্যবহারিক বাংলা',
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

  @override
  void initState() {
    super.initState();
    loadWords();
    // isSearchBarOpen = !isSearchBarOpen;
  }

  Future<void> loadWords() async {
    try {
      // Check if the JSON file exists locally
      // final directory = await getApplicationDocumentsDirectory();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/words.json');
      // final file = File('assets/words.json');

      // print(file);
      if (await file.exists()) {
        // If the file exists locally, load data from it
        final jsonString = await file.readAsString();
        final List<dynamic> jsonData = jsonDecode(jsonString);
        setState(() {
          allWords =
              jsonData.map((wordJson) => Word.fromJson(wordJson)).toList();
          filteredWords = allWords;
          isLoading = false;
        });
      } else {
        // If the file doesn't exist, fetch data from the network and save it locally
        final response = await http.get(
          Uri.parse(
              'https://raw.githubusercontent.com/rajibdpi/govdictionary/latest/assets/words.json'),
        );
        if (response.statusCode == 200) {
          final jsonString = response.body;
          final List<dynamic> jsonData = jsonDecode(jsonString);
          setState(() {
            allWords =
                jsonData.map((wordJson) => Word.fromJson(wordJson)).toList();
            filteredWords = allWords;
            isLoading = false;
          });
          // Save JSON data locally with a custom file name
          await File('${directory.path}/words.json').writeAsString(jsonString);
          // print(jsonString);
        } else {
          throw Exception('Failed to load words');
        }
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
                        showDialogMessage(context, word);
                      },
                      onLongPress: () {
                        print(
                          '${word.correct} - ${word.incorrect}',
                        );
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
                        showDialogMessage(context, word);
                      },
                      onLongPress: () {
                        print(
                          '${word.correct} - ${word.incorrect}',
                        );
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
        title: const Text(
          'সরকারি কাজে ব্যবহারিক বাংলা',
          style: TextStyle(color: Colors.white),
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
        // backgroundColor: Colors.deepPurple.shade50,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Text(
                'সরকারি কাজে ব্যবহারিক বাংলা',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AboutPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to settings page or perform settings related actions
              },
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: FutureBuilder<String>(
                future: lastUpdatedLocalFile(),
                // future: lastUpdatedLocalFile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                      semanticsLabel: 'Loading..',
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text('Updated at: ${snapshot.data}');
                  }
                },
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer
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
