import 'package:govdictionary/components/utils.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
            color: Theme.of(context).appBarTheme.foregroundColor,
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
                          'App Developer',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                AssetImage('assets/images/author.jpg'),
                            // NetworkImage('https://avatars.githubusercontent.com/u/16264930'),
                          ),
                          title: Text(
                            'Rajib Ahmed\nDhaka, Bangladesh',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          // subtitle: Text(
                          //   'App Developer',
                          //   style: Theme.of(context).textTheme.bodyMedium,
                          // ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: PhosphorIcon(
                                PhosphorIcons.linkedinLogo(),
                                // color: Colors.green,
                                size: 32,
                                semanticLabel: 'LinkedIn',
                              ),
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
                                          Text('Could not launch Facebook'),
                                    ),
                                  );
                                }
                              },
                              tooltip: 'LinkedIn',
                            ),
                            IconButton(
                              icon: PhosphorIcon(
                                PhosphorIcons.facebookLogo(),
                                size: 32,
                                semanticLabel: 'Facebook',
                              ),
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
                            IconButton(
                              icon: PhosphorIcon(
                                PhosphorIcons.envelopeSimple(),
                                size: 32,
                                semanticLabel: 'Email',
                              ),
                              onPressed: () {
                                final Uri emailLaunchUri = Uri(
                                  scheme: 'mailto',
                                  path: 'rajibdpi@gmail.com',
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
                              icon: PhosphorIcon(
                                PhosphorIcons.githubLogo(),
                                // color: Colors.green,
                                size: 32,
                                semanticLabel: 'GitHub',
                              ),
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
                              icon: PhosphorIcon(
                                PhosphorIcons.globe(),
                                // color: Colors.green,
                                size: 32,
                                semanticLabel: 'Website',
                              ),
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
                          'Words Stats',
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
                          'Update',
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
                                  ? 'Update available'
                                  : 'Already updated',
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
