import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';

class ThemeController extends ChangeNotifier {
  bool _isDarkMode = false;
  double _fontSize = 16.0; // Default font size
  String _language = 'বাংলা'; // Default language

  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  String get language => _language;

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  ThemeController() {
    _loadSettings();
  }

  // Load saved settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    _language = prefs.getString('language') ?? 'বাংলা';
    notifyListeners();
  }

  // Toggle theme and save
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // Set font size and save
  void setFontSize(double value) async {
    _fontSize = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', _fontSize);
    notifyListeners();
  }

  // Set language and save
  void setLanguage(String value) async {
    _language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _language);
    notifyListeners();
  }

  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primaryLight,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.accentLight,
      surface: AppColors.backgroundLight,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryLight,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
          fontSize: 16.0,
          color: AppColors.textPrimaryLight), // Updated dynamically later
      bodyMedium:
          TextStyle(fontSize: 14.0, color: AppColors.textSecondaryLight),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.textPrimaryLight,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.backgroundLight,
      scrimColor: AppColors.textPrimaryLight,
    ),
    listTileTheme: const ListTileThemeData(
      selectedTileColor: AppColors.accentLight,
      textColor: AppColors.textPrimaryLight,
      iconColor: AppColors.textSecondaryLight,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textSecondaryLight,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: AppColors.textSecondaryLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: AppColors.textSecondaryLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: AppColors.textPrimaryLight),
      ),
      labelStyle: const TextStyle(color: AppColors.textPrimaryLight),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.accentDark,
      surface: AppColors.backgroundDark,
      error: AppColors.error,
      onPrimary: AppColors.textPrimaryDark,
      onSecondary: AppColors.textPrimaryDark,
      onSurface: AppColors.textPrimaryDark,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
          fontSize: 16.0,
          color: AppColors.textPrimaryDark), // Updated dynamically later
      bodyMedium: TextStyle(fontSize: 14.0, color: AppColors.textSecondaryDark),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.backgroundDark,
    ),
    listTileTheme: const ListTileThemeData(
      selectedTileColor: AppColors.accentDark,
      textColor: AppColors.textPrimaryDark,
      iconColor: AppColors.textSecondaryDark,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textSecondaryDark,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: AppColors.textSecondaryDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: AppColors.textSecondaryDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: AppColors.primaryLight),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
    ),
    useMaterial3: true,
  );

  // Update textTheme with current fontSize
  ThemeData get updatedTheme {
    final baseTheme = _isDarkMode ? darkTheme : lightTheme;
    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.copyWith(
        bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(fontSize: _fontSize),
        bodyMedium:
            baseTheme.textTheme.bodyMedium?.copyWith(fontSize: _fontSize - 2),
      ),
    );
  }
}
