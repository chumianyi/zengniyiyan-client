import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'neu.dart';

void main() {
  runApp(const ZengniyiyanApp());
}

class ZengniyiyanApp extends StatefulWidget {
  const ZengniyiyanApp({super.key});

  @override
  State<ZengniyiyanApp> createState() => _ZengniyiyanAppState();
}

class _ZengniyiyanAppState extends State<ZengniyiyanApp> {
  bool _dark = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool('dark_mode') ?? false;
    if (!mounted) return;
    setState(() => _dark = dark);
  }

  Future<void> _toggleTheme() async {
    final next = !_dark;
    setState(() => _dark = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', next);
  }

  @override
  Widget build(BuildContext context) {
    final lightColors = NeuColors.light;
    final darkColors = NeuColors.dark;

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightColors.bg,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkColors.bg,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );

    return MaterialApp(
      title: '赠你一言',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: HomeScreen(
        dark: _dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
