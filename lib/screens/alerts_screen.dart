
import 'package:flutter/material.dart';

import '../controllers/weather_controller.dart';
import '../core/theme/app_theme.dart';
import '../models/territorial_alert.dart';
import '../services/territorial_alert_engine.dart';

class AlertsScreen extends StatelessWidget {
  final WeatherController controller;

  const AlertsScreen({
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
              'Alertas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Atualizar alertas',
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Analisando previsões meteorológicas...'),
          ],
        ),
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
                    'Dados indisponíveis para análise.',
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

    final weather = controller.weather!;

    final alerts = const TerritorialAlertEngine()
        .evaluate(weather);

    final date = weather.referenceTime;

    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')} '
        'às ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

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
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 36,
              ),
              SizedBox(height: 16),
              Text(
                'Alertas preventivos',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Análise indicativa de condições '
                'meteorológicas que podem exigir '
                'atenção dos gestores públicos.',
                style: TextStyle(
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            const Icon(
              Icons.schedule,
              size: 17,
              color: Colors.black54,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Referência: $formattedDate · São Paulo',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        const Text(
          'Horizonte analisado: próximas 24 horas.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),

        if (controller.isLoading) ...[
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
        ],

        if (controller.error != null) ...[
          const SizedBox(height: 16),
          _InformationBox(
            icon: Icons.info_outline,
            message:
                '${controller.error} '
                'Os alertas utilizam a última '
                'previsão disponível.',
          ),
        ],

        const SizedBox(height: 26),

        Text(
          '${alerts.length} alerta(s) identificado(s)',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        if (alerts.isEmpty)
          _NoAlertsCard()
        else
          ...alerts.map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _AlertCard(alert: alert),
            ),
          ),

        const SizedBox(height: 12),

        const _InformationBox(
          icon: Icons.verified_user_outlined,
          message:
              'Esses alertas são indicativos e utilizam '
              'regras demonstrativas, não calibradas. '
              'A confiança exibida não é uma probabilidade '
              'estatística. Consulte órgãos oficiais e '
              'avalie o contexto local antes de decidir. '
              'O aplicativo não executa intervenções '
              'automaticamente.',
        ),

        const SizedBox(height: 18),

        const Text(
          'Fonte: Open-Meteo. Previsões sujeitas '
          'a mudanças e incertezas.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _NoAlertsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.support,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.accent,
            size: 40,
          ),
          SizedBox(height: 14),
          Text(
            'Nenhum sinal acima dos limiares',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Os indicadores analisados não atingiram '
            'os limites demonstrativos configurados. '
            'Isso não significa ausência de riscos '
            'no território.',
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.5,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final TerritorialAlert alert;

  const _AlertCard({
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final isElevated =
        alert.severity == AlertSeverity.elevated;

    final statusColor = isElevated
        ? const Color(0xFF9A3412)
        : const Color(0xFF875A00);

    final statusBackground = isElevated
        ? const Color(0xFFFFEDE7)
        : const Color(0xFFFFF4DC);

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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                isElevated
                    ? Icons.warning_rounded
                    : Icons.info_outline,
                color: statusColor,
              ),
              Text(
                alert.severityLabel,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Nível ${alert.severityLabel.toLowerCase()}',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            alert.title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            alert.metricSummary,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Divider(height: 28),

          _detail(
            'Justificativa',
            alert.justification,
          ),

          _detail(
            'Confiança indicativa: '
            '${alert.confidenceLabel}',
            alert.confidenceReason,
          ),

          _detail(
            'Limitações da análise',
            alert.limitations,
          ),

          _detail(
            'Apoio à decisão',
            alert.recommendation,
          ),
        ],
      ),
    );
  }

  Widget _detail(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: Colors.black87,
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationBox extends StatelessWidget {
  final IconData icon;
  final String message;

  const _InformationBox({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.support,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
