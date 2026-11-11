
import 'package:flutter/foundation.dart';

import '../models/territorial_record.dart';

class RecordController extends ChangeNotifier {
  final List<TerritorialRecord> _records = [];

  List<TerritorialRecord> get records =>
      List.unmodifiable(_records);

  int get totalRecords => _records.length;

  void addRecord({
    required String title,
    required String area,
    required String description,
    required RecordCategory category,
  }) {
    final cleanTitle = title.trim();
    final cleanArea = area.trim();
    final cleanDescription = description.trim();

    if (cleanTitle.length < 5 ||
        cleanArea.length < 3 ||
        cleanDescription.length < 10) {
      throw ArgumentError(
        'Os dados da observação são inválidos.',
      );
    }

    final now = DateTime.now();

    final record = TerritorialRecord(
      id: '${now.microsecondsSinceEpoch}-${_records.length}',
      title: cleanTitle,
      area: cleanArea,
      description: cleanDescription,
      category: category,
      createdAt: now,
    );

    _records.insert(0, record);

    notifyListeners();
  }

  bool removeRecord(String id) {
    final previousLength = _records.length;

    _records.removeWhere(
      (record) => record.id == id,
    );

    if (_records.length == previousLength) {
      return false;
    }

    notifyListeners();
    return true;
  }
}
