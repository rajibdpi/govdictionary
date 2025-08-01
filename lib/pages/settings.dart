import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:govdictionary/components/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'সেটিংস',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: themeController.fontSize,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Toggle
          ListTile(
            title: Text(
              'থিম',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: themeController.fontSize,
              ),
            ),
            subtitle: Text(
              themeController.isDarkMode ? 'ডার্ক মোড' : 'লাইট মোড',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            trailing: Switch(
              value: themeController.isDarkMode,
              onChanged: (value) {
                themeController.toggleTheme();
              },
            ),
          ),
          // Font Size Slider
          ListTile(
            title: Text(
              'ফন্ট সাইজ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: themeController.fontSize,
              ),
            ),
            subtitle: Text(
              '${themeController.fontSize.toInt()}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Slider(
            value: themeController.fontSize,
            min: 12.0,
            max: 24.0,
            divisions: 12,
            label: themeController.fontSize.toInt().toString(),
            onChanged: (value) {
              themeController.setFontSize(value);
            },
          ),
          // Language Selection
          ListTile(
            title: Text(
              'ভাষা',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: themeController.fontSize,
              ),
            ),
            subtitle: Text(
              themeController.language,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'বাংলা',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onTap: () {
              themeController.setLanguage('বাংলা');
            },
          ),
          ListTile(
            title: Text(
              'English',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onTap: () {
              themeController.setLanguage('English');
            },
          ),
        ],
      ),
    );
  }
}
