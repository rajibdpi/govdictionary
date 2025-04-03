import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:govdictionary/components/theme_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
                  subtitle: Text('${themeController.fontSize.toInt()}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Slider(
                    value: themeController.fontSize,
                    min: 12,
                    max: 24,
                    divisions: 12,
                    label: themeController.fontSize.toInt().toString(),
                    onChanged: (value) {
                      themeController.setFontSize(value);
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
              subtitle: Text(themeController.language),
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
                            themeController.setLanguage('বাংলা');
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('English'),
                          onTap: () {
                            themeController.setLanguage('English');
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
