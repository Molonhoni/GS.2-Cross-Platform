
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_data.dart';

class WeatherException implements Exception {
  final String message;

  const WeatherException(this.message);

  @override
  String toString() => message;
}

class WeatherService {
  final http.Client? client;

  WeatherService({this.client});

  static final Uri _url = Uri.https(
    'api.open-meteo.com',
    '/v1/forecast',
    {
      'latitude': '-23.5505',
      'longitude': '-46.6333',
      'current':
          'temperature_2m,relative_humidity_2m,precipitation',
      'daily': 'precipitation_probability_max',
      'forecast_days': '3',
      'timezone': 'America/Sao_Paulo',
    },
  );

  Future<WeatherData> fetchWeather() async {
    final httpClient = client ?? http.Client();

    try {
      final response = await httpClient
          .get(_url)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw const WeatherException(
          'Serviço meteorológico indisponível.',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('JSON inválido');
      }

      return WeatherData.fromJson(decoded);
    } on WeatherException {
      rethrow;
    } on TimeoutException {
      throw const WeatherException(
        'A consulta demorou demais. Tente novamente.',
      );
    } on http.ClientException {
      throw const WeatherException(
        'Não foi possível conectar ao serviço meteorológico.',
      );
    } on FormatException {
      throw const WeatherException(
        'A API retornou dados inválidos.',
      );
    } catch (_) {
      throw const WeatherException(
        'Não foi possível carregar os dados climáticos.',
      );
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }
}
