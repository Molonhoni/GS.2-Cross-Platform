
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TerritorioVivoApp());
}

class TerritorioVivoApp extends StatelessWidget {
  const TerritorioVivoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Território Vivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
