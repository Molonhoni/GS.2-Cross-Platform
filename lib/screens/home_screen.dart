
import 'package:flutter/material.dart';

import '../controllers/weather_controller.dart';
import '../core/theme/app_theme.dart';
import '../widgets/module_card.dart';
import '../widgets/weather_overview_card.dart';

class HomeScreen extends StatelessWidget {
  final WeatherController weatherController;

  const HomeScreen({
    super.key,
    required this.weatherController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Território Vivo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.accent,
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_city_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Inteligência territorial',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Informações que ajudam a construir '
                    'cidades mais preparadas e sustentáveis.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            WeatherOverviewCard(
              controller: weatherController,
            ),

            const SizedBox(height: 30),

            const Text(
              'Painel de monitoramento',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Conheça os módulos da plataforma.',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 22),

            const ModuleCard(
              icon: Icons.cloud_outlined,
              title: 'Clima e indicadores',
              description:
                  'Monitoramento das condições climáticas.',
            ),

            const ModuleCard(
              icon: Icons.show_chart_rounded,
              title: 'Tendências',
              description:
                  'Análise da evolução dos indicadores.',
            ),

            const ModuleCard(
              icon: Icons.warning_amber_rounded,
              title: 'Alertas preventivos',
              description:
                  'Identificação de possíveis situações de risco.',
            ),

            const ModuleCard(
              icon: Icons.assignment_outlined,
              title: 'Registros de campo',
              description:
                  'Cadastro e consulta de observações.',
            ),

            const SizedBox(height: 12),

            const Text(
              'Os módulos estão em preparação. '
              'Novas funcionalidades serão integradas '
              'nas próximas versões.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
