
import 'package:flutter/foundation.dart';

import '../models/weather_data.dart';
import '../services/weather_service.dart';

class WeatherController extends ChangeNotifier {
  final WeatherService _weatherService;

  WeatherController(this._weatherService);

  WeatherData? _weather;
  bool _isLoading = false;
  bool _isDisposed = false;
  String? _error;

  WeatherData? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _weather != null;

  Future<void> loadWeather() async {
    if (_isDisposed || _isLoading) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _weatherService.fetchWeather();

      if (_isDisposed) {
        return;
      }

      _weather = result;
    } on WeatherException catch (exception) {
      if (_isDisposed) {
        return;
      }

      _error = exception.message;
    } catch (_) {
      if (_isDisposed) {
        return;
      }

      _error = 'Não foi possível atualizar os dados climáticos.';
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
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
