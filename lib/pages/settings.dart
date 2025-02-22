import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:govdictionary/components/theme_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double fontSize = 16.0;
  String selectedLanguage = 'বাংলা';

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable dark theme'),
              trailing: Switch(
                value: themeController.isDarkMode,
                onChanged: (value) {
                  themeController.toggleTheme();
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Font Size'),
                  subtitle: Text('${fontSize.toInt()}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Slider(
                    value: fontSize,
                    min: 12,
                    max: 24,
                    divisions: 12,
                    label: fontSize.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        fontSize = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('Language'),
              subtitle: Text(selectedLanguage),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Language'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('বাংলা'),
                          onTap: () {
                            setState(() {
                              selectedLanguage = 'বাংলা';
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('English'),
                          onTap: () {
                            setState(() {
                              selectedLanguage = 'English';
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}