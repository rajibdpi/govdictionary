import 'package:flutter/material.dart';
import 'package:govdictionary/components/theme_controller.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: Provider.of<ThemeController>(context).fontSize,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Profile page is under construction.',
            style: TextStyle(
              fontSize: Provider.of<ThemeController>(context).fontSize,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
