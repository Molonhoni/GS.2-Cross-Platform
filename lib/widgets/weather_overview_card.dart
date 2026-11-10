
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';

class WeatherOverviewCard extends StatefulWidget {
  final WeatherService? service;

  const WeatherOverviewCard({super.key, this.service});

  @override
  State<WeatherOverviewCard> createState() =>
      _WeatherOverviewCardState();
}

class _WeatherOverviewCardState
    extends State<WeatherOverviewCard> {
  late final WeatherService _service;
  late Future<WeatherData> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? WeatherService();
    _weatherFuture = _service.fetchWeather();
  }

  void _refresh() {
    setState(() {
      _weatherFuture = _service.fetchWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.support),
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
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const Text(
            'São Paulo, SP',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 18),
          FutureBuilder<WeatherData>(
            future: _weatherFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState !=
                  ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Consultando dados climáticos...'),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Column(
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      color: Colors.orange,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error?.toString() ??
                          'Dados indisponíveis.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                );
              }

              final data = snapshot.data!;

              final hour = data.referenceTime.hour
                  .toString()
                  .padLeft(2, '0');
              final minute = data.referenceTime.minute
                  .toString()
                  .padLeft(2, '0');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        crossAxisCount:
                            constraints.maxWidth >= 700 ? 4 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
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
                    'Horário de referência: $hour:$minute',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'Fonte: Open-Meteo. Dados meteorológicos '
            'modelados, sujeitos a incertezas. '
            'A probabilidade exibida é o máximo '
            'previsto para hoje, não um alerta oficial.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
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
          Icon(icon, color: AppColors.accent),
          const SizedBox(height: 7),
          Text(
            value,
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
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
