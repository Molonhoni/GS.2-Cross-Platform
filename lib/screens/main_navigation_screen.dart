
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'home_screen.dart';
import 'module_placeholder_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),

    ModulePlaceholderScreen(
      title: 'Tendências',
      headline: 'Evolução dos indicadores',
      description:
          'Acompanhe tendências climáticas e '
          'informações relevantes para o território.',
      icon: Icons.show_chart_rounded,
      plannedFeatures: [
        'Gráficos de temperatura',
        'Previsão de precipitação',
        'Análise de tendências climáticas',
      ],
    ),

    ModulePlaceholderScreen(
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

    ModulePlaceholderScreen(
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
            selectedIcon:
                Icon(Icons.dashboard_rounded),
            label: 'Painel',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon:
                Icon(Icons.show_chart_rounded),
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
            selectedIcon:
                Icon(Icons.assignment_rounded),
            label: 'Registros',
          ),
        ],
      ),
    );
  }
}
