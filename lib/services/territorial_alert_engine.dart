
import 'dart:math' as math;

import '../models/territorial_alert.dart';
import '../models/weather_data.dart';

class TerritorialAlertEngine {
  const TerritorialAlertEngine();

  List<TerritorialAlert> evaluate(WeatherData weather) {
    final forecast = weather.hourlyForecast
        .take(24)
        .toList(growable: false);

    if (forecast.isEmpty) {
      return const [];
    }

    final alerts = <TerritorialAlert>[];

    final totalRain = forecast.fold<double>(
      0,
      (total, hour) => total + hour.precipitation,
    );

    final peakRain = forecast.fold<double>(
      0,
      (highest, hour) =>
          math.max(highest, hour.precipitation),
    );

    final maxTemperature = forecast.fold<double>(
      weather.temperature,
      (highest, hour) =>
          math.max(highest, hour.temperature),
    );

    final hotHours = forecast
        .where((hour) => hour.temperature >= 31)
        .length;

    // REGRA 01 - PRECIPITAÇÃO
    final elevatedRain =
        totalRain >= 30 || peakRain >= 10;

    final attentionRain =
        totalRain >= 12 || peakRain >= 4;

    if (elevatedRain || attentionRain) {
      final rainEvidenceCount =
          (totalRain >= 12 ? 1 : 0) +
          (peakRain >= 4 ? 1 : 0);

      final confidence = rainEvidenceCount >= 2
          ? AlertConfidence.moderate
          : AlertConfidence.low;

      alerts.add(
        TerritorialAlert(
          id: 'precipitation',
          title: elevatedRain
              ? 'Precipitação intensa prevista'
              : 'Atenção à precipitação',
          severity: elevatedRain
              ? AlertSeverity.elevated
              : AlertSeverity.attention,
          confidence: confidence,
          metricSummary:
              '${totalRain.toStringAsFixed(1)} mm '
              'acumulados nas próximas 24h',
          justification:
              'A previsão indica um acumulado de '
              '${totalRain.toStringAsFixed(1)} mm '
              'e um pico horário de '
              '${peakRain.toStringAsFixed(1)} mm. '
              'Um ou mais limiares demonstrativos '
              'de precipitação foram atingidos.',
          confidenceReason:
              confidence == AlertConfidence.moderate
                  ? 'Dois indicadores de precipitação '
                    'atingiram os critérios utilizados. '
                    'A confiança é apenas indicativa.'
                  : 'Somente um indicador atingiu o '
                    'critério. A evidência é limitada.',
          limitations:
              'A análise considera apenas a previsão '
              'meteorológica. Não incorpora relevo, '
              'drenagem, ocupação do solo, histórico '
              'de alagamentos nem vulnerabilidade '
              'dos bairros. Não é uma previsão '
              'validada de enchentes.',
          recommendation:
              'Consultar os avisos oficiais da '
              'Defesa Civil e verificar as condições '
              'das áreas mais vulneráveis antes de '
              'definir qualquer medida operacional.',
        ),
      );
    }

    // REGRA 02 - TEMPERATURA
    final elevatedHeat = maxTemperature >= 34;
    final attentionHeat = maxTemperature >= 31;

    if (elevatedHeat || attentionHeat) {
      final confidence = hotHours >= 3
          ? AlertConfidence.moderate
          : AlertConfidence.low;

      alerts.add(
        TerritorialAlert(
          id: 'heat',
          title: elevatedHeat
              ? 'Temperatura elevada prevista'
              : 'Atenção à temperatura',
          severity: elevatedHeat
              ? AlertSeverity.elevated
              : AlertSeverity.attention,
          confidence: confidence,
          metricSummary:
              'Pico previsto de '
              '${maxTemperature.toStringAsFixed(1)} °C',
          justification:
              'A temperatura poderá atingir '
              '${maxTemperature.toStringAsFixed(1)} °C. '
              'A previsão apresenta $hotHours hora(s) '
              'com temperatura igual ou superior '
              'a 31 °C no horizonte analisado.',
          confidenceReason:
              confidence == AlertConfidence.moderate
                  ? 'O limite de temperatura aparece '
                    'em pelo menos três horários da '
                    'previsão. A confiança é indicativa.'
                  : 'A elevação aparece em poucos '
                    'horários, com evidência limitada.',
          limitations:
              'A análise utiliza temperatura do ar '
              'prevista, sem considerar índice de '
              'calor, exposição solar, ilhas de calor, '
              'condições de saúde ou vulnerabilidade '
              'individual. Não caracteriza, por si '
              'só, uma onda de calor oficial.',
          recommendation:
              'Avaliar orientações preventivas sobre '
              'hidratação, exposição ao calor e '
              'atenção a grupos vulneráveis, '
              'consultando também os órgãos oficiais.',
        ),
      );
    }

    // Organiza primeiro os alertas mais relevantes.
    alerts.sort((a, b) {
      return b.severity.index.compareTo(
        a.severity.index,
      );
    });

    return alerts;
  }
}
