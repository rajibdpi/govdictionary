import 'package:govdictionary/components/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:govdictionary/components/theme_controller.dart';

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
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "About",
          style: TextStyle(
            fontSize: Provider.of<ThemeController>(context).fontSize,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map>(
          future: fileStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Author Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Rajib Ahmed',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            'Software Developer',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.email),
                              onPressed: () {
                                final Uri emailLaunchUri = Uri(
                                  scheme: 'mailto',
                                  path: 'rajibahmed.cse@gmail.com',
                                );
                                try {
                                  launchUrl(emailLaunchUri,
                                      mode: LaunchMode.platformDefault);
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Could not launch email client'),
                                    ),
                                  );
                                }
                              },
                              tooltip: 'Email',
                            ),
                            IconButton(
                              icon: const Icon(Icons.language),
                              onPressed: () {
                                final Uri websiteUri =
                                    Uri.parse('https://rajibdpi.github.io');
                                try {
                                  launchUrl(websiteUri,
                                      mode: LaunchMode.platformDefault);
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Could not launch website'),
                                    ),
                                  );
                                }
                              },
                              tooltip: 'Website',
                            ),
                            IconButton(
                              icon: const Icon(Icons.code),
                              onPressed: () {
                                final Uri githubUri =
                                    Uri.parse('https://github.com/rajibdpi');
                                try {
                                  launchUrl(githubUri,
                                      mode: LaunchMode.platformDefault);
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Could not launch GitHub'),
                                    ),
                                  );
                                }
                              },
                              tooltip: 'GitHub',
                            ),
                            IconButton(
                              icon: const Icon(Icons.person),
                              onPressed: () {
                                final Uri linkedinUri = Uri.parse(
                                    'https://linkedin.com/in/rajibdpi');
                                try {
                                  launchUrl(linkedinUri,
                                      mode: LaunchMode.platformDefault);
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Could not launch LinkedIn'),
                                    ),
                                  );
                                }
                              },
                              tooltip: 'LinkedIn',
                            ),
                            IconButton(
                              icon: const Icon(Icons.facebook),
                              onPressed: () {
                                final Uri facebookUri =
                                    Uri.parse('https://facebook.com/rajibdpi');
                                try {
                                  launchUrl(facebookUri,
                                      mode: LaunchMode.platformDefault);
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Could not launch Facebook'),
                                    ),
                                  );
                                }
                              },
                              tooltip: 'Facebook',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'App Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ...snapshot.data!.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${entry.key}:',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  '${entry.value}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Updates',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: FilledButton.icon(
                            onPressed: updateAvailable() == true
                                ? () {
                                    saveUpdate();
                                  }
                                : null,
                            icon: Icon(
                              updateAvailable() == true
                                  ? Icons.system_update
                                  : Icons.check_circle,
                            ),
                            label: Text(
                              updateAvailable() == true
                                  ? 'Update Available'
                                  : 'Already Updated',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
