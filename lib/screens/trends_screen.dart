
import 'package:flutter/material.dart';

import '../controllers/weather_controller.dart';
import '../core/theme/app_theme.dart';
import '../widgets/forecast_charts.dart';

class TrendsScreen extends StatelessWidget {
  final WeatherController controller;

  const TrendsScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Tendências',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Atualizar previsões',
                onPressed: controller.isLoading
                    ? null
                    : () {
                        controller.loadWeather();
                      },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: SafeArea(
            child: _buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (controller.isLoading && !controller.hasData) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!controller.hasData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 42,
                color: AppColors.accent,
              ),
              const SizedBox(height: 14),
              Text(
                controller.error ??
                    'Previsões indisponíveis.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () {
                  controller.loadWeather();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final data = controller.weather!;
    final forecast = data.hourlyForecast;

    return ListView(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.show_chart_rounded,
                color: Colors.white,
                size: 36,
              ),
              SizedBox(height: 16),
              Text(
                'Análise de tendências',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Acompanhe a previsão meteorológica '
                'para as próximas 24 horas em São Paulo.',
                style: TextStyle(
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        if (controller.isLoading) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 14),
        ],

        if (controller.error != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${controller.error} '
              'Exibindo a última previsão disponível.',
            ),
          ),
          const SizedBox(height: 18),
        ],

        TemperatureForecastCard(
          forecast: forecast,
        ),

        const SizedBox(height: 18),

        PrecipitationForecastCard(
          forecast: forecast,
        ),

        const SizedBox(height: 22),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.support,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Sobre as previsões',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Fonte: Open-Meteo. As informações são '
                'previsões meteorológicas e podem mudar '
                'conforme os modelos são atualizados. '
                'Não representam medições locais em tempo '
                'real nem garantem a ocorrência de eventos.',
                style: TextStyle(
                  color: AppColors.primary,
                  height: 1.5,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
