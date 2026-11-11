
enum AlertSeverity {
  attention,
  elevated,
}

enum AlertConfidence {
  low,
  moderate,
}

class TerritorialAlert {
  final String id;
  final String title;
  final AlertSeverity severity;
  final AlertConfidence confidence;
  final String metricSummary;
  final String justification;
  final String confidenceReason;
  final String limitations;
  final String recommendation;

  const TerritorialAlert({
    required this.id,
    required this.title,
    required this.severity,
    required this.confidence,
    required this.metricSummary,
    required this.justification,
    required this.confidenceReason,
    required this.limitations,
    required this.recommendation,
  });

  String get severityLabel {
    switch (severity) {
      case AlertSeverity.attention:
        return 'Atenção';
      case AlertSeverity.elevated:
        return 'Elevado';
    }
  }

  String get confidenceLabel {
    switch (confidence) {
      case AlertConfidence.low:
        return 'Baixa';
      case AlertConfidence.moderate:
        return 'Moderada';
    }
  }
}
