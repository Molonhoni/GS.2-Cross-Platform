
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/weather_data.dart';
import 'forecast_charts.dart';

enum ForecastChartType {
  temperature,
  precipitation,
}

class AccessibleForecastChart extends StatelessWidget {
  final List<ForecastHour> forecast;
  final ForecastChartType type;

  const AccessibleForecastChart({
    super.key,
    required this.forecast,
    required this.type,
  });

  String _buildSummary() {
    if (forecast.isEmpty) {
      return 'Nenhuma previsão disponível.';
    }

    if (type == ForecastChartType.temperature) {
      final temperatures = forecast
          .map((hour) => hour.temperature)
          .toList();

      final minimum = temperatures.reduce(math.min);
      final maximum = temperatures.reduce(math.max);

      return 'Temperatura prevista: mínima de '
          '${minimum.toStringAsFixed(1)} graus Celsius '
          'e máxima de '
          '${maximum.toStringAsFixed(1)} graus Celsius '
          'nas próximas ${forecast.length} horas.';
    }

    final totalRain = forecast.fold<double>(
      0,
      (sum, hour) => sum + hour.precipitation,
    );

    final peakRain = forecast.fold<double>(
      0,
      (peak, hour) =>
          math.max(peak, hour.precipitation),
    );

    return 'Precipitação prevista: acumulado de '
        '${totalRain.toStringAsFixed(1)} milímetros, '
        'com pico horário de '
        '${peakRain.toStringAsFixed(1)} milímetros '
        'nas próximas ${forecast.length} horas.';
  }

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) {
      return const SizedBox.shrink();
    }

    final summary = _buildSummary();

    final chart = type == ForecastChartType.temperature
        ? TemperatureForecastCard(forecast: forecast)
        : PrecipitationForecastCard(forecast: forecast);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          container: true,
          label: summary,
          child: chart,
        ),

        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.support,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ExcludeSemantics(
                child: Icon(
                  Icons.analytics_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Resumo: $summary',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
