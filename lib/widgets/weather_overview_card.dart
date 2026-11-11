
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controllers/weather_controller.dart';
import '../core/theme/app_theme.dart';
import '../models/weather_data.dart';

class WeatherOverviewCard extends StatelessWidget {
  final WeatherController controller;

  const WeatherOverviewCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.support,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.cloud_outlined,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Condições climáticas',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Atualizar informações',
                    onPressed: controller.isLoading
                        ? null
                        : () {
                            controller.loadWeather();
                          },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),

              const Text(
                'São Paulo, SP',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 18),

              if (controller.isLoading &&
                  !controller.hasData)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text(
                          'Consultando dados climáticos...',
                        ),
                      ],
                    ),
                  ),
                )
              else if (!controller.hasData)
                _ErrorContent(
                  message: controller.error ??
                      'Dados meteorológicos indisponíveis.',
                  onRetry: () {
                    controller.loadWeather();
                  },
                )
              else
                _WeatherContent(
                  data: controller.weather!,
                  isLoading: controller.isLoading,
                  error: controller.error,
                ),

              const SizedBox(height: 14),

              const Text(
                'Fonte: Open-Meteo. Dados meteorológicos '
                'modelados e sujeitos a incertezas. '
                'A probabilidade exibida é o máximo '
                'previsto para hoje, não um alerta oficial.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WeatherContent extends StatelessWidget {
  final WeatherData data;
  final bool isLoading;
  final String? error;

  const _WeatherContent({
    required this.data,
    required this.isLoading,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final hour = data.referenceTime.hour
        .toString()
        .padLeft(2, '0');

    final minute = data.referenceTime.minute
        .toString()
        .padLeft(2, '0');

    final day = data.referenceTime.day
        .toString()
        .padLeft(2, '0');

    final month = data.referenceTime.month
        .toString()
        .padLeft(2, '0');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoading) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 16),
          const Text(
            'Atualizando informações...',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (error != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF995B00),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$error '
                    'Exibindo os últimos dados disponíveis.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF713F00),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        LayoutBuilder(
          builder: (context, constraints) {
            // Corrige o overflow em telas menores.
            // Cada indicador recebe altura suficiente
            // para ícone, valor e descrição.
            //
            // Em fontes ampliadas, a altura também
            // aumenta para preservar a acessibilidade.

            final textScale =
                MediaQuery.textScalerOf(context).scale(1.0);

            final tileHeight =
                150.0 * math.max(1.0, textScale);

            final columns =
                constraints.maxWidth >= 700 ? 4 : 2;

            return GridView.count(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: tileHeight,
              children: [
                _MetricTile(
                  icon: Icons.thermostat_outlined,
                  label: 'Temperatura',
                  value:
                      '${data.temperature.toStringAsFixed(1)} °C',
                ),
                _MetricTile(
                  icon: Icons.water_drop_outlined,
                  label: 'Umidade',
                  value: '${data.humidity}%',
                ),
                _MetricTile(
                  icon: Icons.grain_outlined,
                  label: 'Precipitação',
                  value:
                      '${data.precipitation.toStringAsFixed(1)} mm',
                ),
                _MetricTile(
                  icon: Icons.umbrella_outlined,
                  label: 'Máx. prob. chuva hoje',
                  value:
                      '${data.maxRainProbabilityToday}%',
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 14),

        Text(
          'Referência meteorológica: '
          '$day/$month às $hour:$minute',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorContent({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off,
            size: 34,
            color: Colors.orange,
          ),

          const SizedBox(height: 12),

          Text(
            message,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.accent,
            size: 24,
          ),

          const SizedBox(height: 7),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            label,
            textAlign: TextAlign.center,
            softWrap: true,
            style: const TextStyle(
              fontSize: 11,
              height: 1.3,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
