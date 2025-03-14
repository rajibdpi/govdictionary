import 'package:govdictionary/components/utils.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  final String networkConnectionStatus;
  const AboutPage({super.key, required this.networkConnectionStatus});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.teal,
        // actions: [],
        title: const Text(
          "About",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: FutureBuilder<Map>(
            future: fileStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While waiting for the future to complete, you can display a loading indicator or placeholder text
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // If there's an error, you can display an error message
                return Text('Error: ${snapshot.error}');
              } else {
                // If the future completes successfully, display the last update time
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: updateAvailable() == true
                          ? () {
                              saveUpdate();
                            }
                          : null,
                      label: updateAvailable() == true
                          ? const Text('Update Available')
                          : const Text('Already Updated'),
                    ),
                    Text(
                      snapshot.data!.entries
                          .map((entry) => '${entry.key}: ${entry.value}')
                          .join('\n'),
                    ),
                    // Text('${widget.networkConnectionStatus}'),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
