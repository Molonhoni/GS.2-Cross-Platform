
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'core/theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';
import 'services/record_repository.dart';
import 'services/weather_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const TerritorioVivoApp());

  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }
}

class TerritorioVivoApp extends StatelessWidget {
  final WeatherService? weatherService;
  final RecordRepository? recordRepository;

  const TerritorioVivoApp({
    super.key,
    this.weatherService,
    this.recordRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Território Vivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: MainNavigationScreen(
        weatherService: weatherService,
        recordRepository: recordRepository,
      ),
    );
  }
}
