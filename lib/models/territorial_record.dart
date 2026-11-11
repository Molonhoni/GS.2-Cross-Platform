
enum RecordCategory {
  rainfall,
  waste,
  infrastructure,
  water,
  other,
}

extension RecordCategoryLabel on RecordCategory {
  String get label {
    switch (this) {
      case RecordCategory.rainfall:
        return 'Chuva e drenagem';
      case RecordCategory.waste:
        return 'Resíduos e limpeza';
      case RecordCategory.infrastructure:
        return 'Infraestrutura urbana';
      case RecordCategory.water:
        return 'Água e abastecimento';
      case RecordCategory.other:
        return 'Outras observações';
    }
  }
}

class TerritorialRecord {
  final String id;
  final String title;
  final String area;
  final String description;
  final RecordCategory category;
  final DateTime createdAt;

  const TerritorialRecord({
    required this.id,
    required this.title,
    required this.area,
    required this.description,
    required this.category,
    required this.createdAt,
  });
}
