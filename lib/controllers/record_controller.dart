
import 'package:flutter/foundation.dart';

import '../models/territorial_record.dart';
import '../services/record_repository.dart';

class RecordController extends ChangeNotifier {
  final RecordRepository _repository;

  RecordController({
    RecordRepository? repository,
  }) : _repository =
           repository ?? SharedPreferencesRecordRepository();

  final List<TerritorialRecord> _records = [];

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isReady = false;
  bool _isDisposed = false;

  String? _error;

  List<TerritorialRecord> get records =>
      List.unmodifiable(_records);

  int get totalRecords => _records.length;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isReady => _isReady;
  bool get isBusy => _isLoading || _isSaving;

  String? get error => _error;

  Future<void> loadRecords() async {
    if (_isDisposed || isBusy) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final storedRecords = await _repository.load();

      if (_isDisposed) {
        return;
      }

      _records
        ..clear()
        ..addAll(storedRecords);

      _isReady = true;
    } catch (_) {
      if (_isDisposed) {
        return;
      }

      _isReady = false;
      _error =
          'Não foi possível recuperar os registros locais.';
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> addRecord({
    required String title,
    required String area,
    required String description,
    required RecordCategory category,
  }) async {
    if (_isDisposed || !_isReady || isBusy) {
      return false;
    }

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

    final updatedRecords = [
      record,
      ..._records,
    ];

    return _saveRecords(updatedRecords);
  }

  Future<bool> removeRecord(String id) async {
    if (_isDisposed || !_isReady || isBusy) {
      return false;
    }

    final updatedRecords = _records
        .where((record) => record.id != id)
        .toList();

    if (updatedRecords.length == _records.length) {
      return false;
    }

    return _saveRecords(updatedRecords);
  }

  // PRIVACIDADE: exclusão de todos os registros locais.
  Future<bool> clearRecords() async {
    if (_isDisposed || !_isReady || isBusy) {
      return false;
    }

    if (_records.isEmpty) {
      return true;
    }

    return _saveRecords([]);
  }

  Future<bool> _saveRecords(
    List<TerritorialRecord> updatedRecords,
  ) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.save(updatedRecords);

      if (_isDisposed) {
        return false;
      }

      _records
        ..clear()
        ..addAll(updatedRecords);

      return true;
    } catch (_) {
      if (_isDisposed) {
        return false;
      }

      _error =
          'Não foi possível salvar a alteração localmente.';

      return false;
    } finally {
      if (!_isDisposed) {
        _isSaving = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
