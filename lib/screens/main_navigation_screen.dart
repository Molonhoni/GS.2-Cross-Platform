
import 'package:flutter/material.dart';

import '../controllers/weather_controller.dart';
import '../core/theme/app_theme.dart';
import '../services/weather_service.dart';
import 'home_screen.dart';
import 'module_placeholder_screen.dart';
import 'trends_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final WeatherService? weatherService;

  const MainNavigationScreen({
    super.key,
    this.weatherService,
  });

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final WeatherController _weatherController;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _weatherController = WeatherController(
      widget.weatherService ?? WeatherService(),
    );

    _screens = [
      HomeScreen(
        weatherController: _weatherController,
      ),

      TrendsScreen(
        controller: _weatherController,
      ),

      const ModulePlaceholderScreen(
        title: 'Alertas',
        headline: 'Alertas em preparação',
        description:
            'Identificação preventiva de situações '
            'que podem exigir atenção dos gestores.',
        icon: Icons.warning_amber_rounded,
        plannedFeatures: [
          'Identificação de riscos potenciais',
          'Justificativa e nível de confiança',
          'Limitações e recomendações',
        ],
      ),

      const ModulePlaceholderScreen(
        title: 'Registros',
        headline: 'Registros em preparação',
        description:
            'Organize observações sobre as '
            'condições do território monitorado.',
        icon: Icons.assignment_outlined,
        plannedFeatures: [
          'Cadastro de observações',
          'Validação dos formulários',
          'Histórico de registros locais',
        ],
      ),
    ];

    _weatherController.loadWeather();
  }

  @override
  void dispose() {
    _weatherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.support,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Painel',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart_rounded),
            label: 'Tendências',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_amber_outlined),
            selectedIcon:
                Icon(Icons.warning_amber_rounded),
            label: 'Alertas',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'Registros',
          ),
        ],
      ),
    );
  }
}
