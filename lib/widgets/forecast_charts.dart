
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/weather_data.dart';

Widget _timeLabel(
  List<ForecastHour> forecast,
  double value,
  TitleMeta meta,
) {
  final index = value.toInt();

  if (index < 0 ||
      index >= forecast.length ||
      index % 6 != 0) {
    return const SizedBox.shrink();
  }

  final hour = forecast[index].time.hour
      .toString()
      .padLeft(2, '0');

  return SideTitleWidget(
    meta: meta,
    space: 8,
    child: Text(
      '${hour}h',
      style: const TextStyle(
        fontSize: 10,
        color: Colors.black54,
      ),
    ),
  );
}

class TemperatureForecastCard extends StatelessWidget {
  final List<ForecastHour> forecast;

  const TemperatureForecastCard({
    super.key,
    required this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) {
      return const SizedBox.shrink();
    }

    final temperatures =
        forecast.map((item) => item.temperature).toList();

    final minTemperature = temperatures.reduce(math.min);
    final maxTemperature = temperatures.reduce(math.max);

    final spots = List.generate(
      forecast.length,
      (index) => FlSpot(
        index.toDouble(),
        forecast[index].temperature,
      ),
    );

    return _ChartContainer(
      title: 'Previsão de temperatura',
      subtitle: 'Próximas 24 horas · °C',
      icon: Icons.thermostat_outlined,
      child: Column(
        children: [
          SizedBox(
            height: 230,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (forecast.length - 1).toDouble(),
                minY: minTemperature - 2,
                maxY: maxTemperature + 2,
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 6,
                      getTitlesWidget: (value, meta) =>
                          _timeLabel(
                        forecast,
                        value,
                        meta,
                      ),
                    ),
                  ),
                ),
                lineTouchData: const LineTouchData(
                  enabled: true,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    color: AppColors.accent,
                    barWidth: 3,
                    isCurved: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.support,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _LegendValue(
                label: 'Mínima prevista',
                value:
                    '${minTemperature.toStringAsFixed(1)} °C',
              ),
              _LegendValue(
                label: 'Máxima prevista',
                value:
                    '${maxTemperature.toStringAsFixed(1)} °C',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PrecipitationForecastCard extends StatelessWidget {
  final List<ForecastHour> forecast;

  const PrecipitationForecastCard({
    super.key,
    required this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) {
      return const SizedBox.shrink();
    }

    final precipitationValues =
        forecast.map((item) => item.precipitation).toList();

    final maxPrecipitation =
        precipitationValues.reduce(math.max);

    final totalPrecipitation =
        precipitationValues.fold<double>(
      0,
      (total, value) => total + value,
    );

    return _ChartContainer(
      title: 'Previsão de precipitação',
      subtitle: 'Próximas 24 horas · mm por hora',
      icon: Icons.water_drop_outlined,
      child: Column(
        children: [
          SizedBox(
            height: 230,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: math.max(
                  1.0,
                  maxPrecipitation + 0.5,
                ),
                alignment: BarChartAlignment.spaceAround,
                groupsSpace: 4,
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 6,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) =>
                          _timeLabel(
                        forecast,
                        value,
                        meta,
                      ),
                    ),
                  ),
                ),
                barGroups: List.generate(
                  forecast.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: forecast[index].precipitation,
                        width: 9,
                        color: AppColors.accent,
                        borderRadius:
                            const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _LegendValue(
            label: 'Precipitação acumulada prevista',
            value:
                '${totalPrecipitation.toStringAsFixed(1)} mm',
          ),
        ],
      ),
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _ChartContainer({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Icon(
                icon,
                color: AppColors.accent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _LegendValue extends StatelessWidget {
  final String label;
  final String value;

  const _LegendValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
