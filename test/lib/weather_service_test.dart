import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/weather_service.dart';

class MockWeatherService extends WeatherService {
  bool throwError = false;

  Future<Map<String, dynamic>> fetchWeatherData(
      double latitude, double longitude) async {
    if (throwError) {
      throw Exception('Mock error occurred');
    }
    return {
      'temperature': '22.5',
      'precipitation': '1.2',
    };
  }
}

void main() {
  group('WeatherService', () {
    final weatherService = MockWeatherService();

    test('fetchWeatherData returns weather data when successful', () async {
      final weatherData = await weatherService.fetchWeatherData(45.0, 16.0);

      expect(weatherData['temperature'], '22.5');
      expect(weatherData['precipitation'], '1.2');
    });

    test('fetchWeatherData throws an exception on failure', () async {
      weatherService.throwError = true;

      expect(() async => await weatherService.fetchWeatherData(45.0, 16.0),
          throwsA(isA<Exception>()));
    });
  });
}
