
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';
import 'services/weather_service.dart';

void main() {
  runApp(const TerritorioVivoApp());
}

class TerritorioVivoApp extends StatelessWidget {
  final WeatherService? weatherService;

  const TerritorioVivoApp({
    super.key,
    this.weatherService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Território Vivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: MainNavigationScreen(
        weatherService: weatherService,
      ),
    );
  }
}
