
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/territorial_record.dart';

abstract class RecordRepository {
  Future<List<TerritorialRecord>> load();

  Future<void> save(
    List<TerritorialRecord> records,
  );
}

class SharedPreferencesRecordRepository
    implements RecordRepository {
  static const String storageKey =
      'territorio_vivo.registros.v1';

  final SharedPreferencesAsync _preferences;

  SharedPreferencesRecordRepository({
    SharedPreferencesAsync? preferences,
  }) : _preferences =
           preferences ?? SharedPreferencesAsync();

  @override
  Future<List<TerritorialRecord>> load() async {
    final storedJson = await _preferences.getString(
      storageKey,
    );

    if (storedJson == null || storedJson.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(storedJson);

    if (decoded is! List) {
      throw const FormatException(
        'Formato de registros inválido.',
      );
    }

    return decoded.map<TerritorialRecord>((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
          'Registro armazenado inválido.',
        );
      }

      return TerritorialRecord.fromJson(item);
    }).toList(growable: false);
  }

  @override
  Future<void> save(
    List<TerritorialRecord> records,
  ) async {
    final serializedRecords = records
        .map((record) => record.toJson())
        .toList();

    final jsonString = jsonEncode(serializedRecords);

    await _preferences.setString(
      storageKey,
      jsonString,
    );
  }
}
