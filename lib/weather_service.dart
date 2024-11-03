import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  // Mock data for quick initial display
  Map<String, dynamic> getMockWeatherData() {
    return {
      'temperature': '22.5',
      'precipitation': '0.5',
    };
  }

  // Fetch real weather data from the API
  Future<Map<String, dynamic>> fetchWeatherData(
      double latitude, double longitude) async {
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,precipitation&timezone=auto');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'temperature': data['hourly']['temperature_2m'][0].toString(),
          'precipitation': data['hourly']['precipitation'][0].toString(),
        };
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      throw Exception('Failed to load weather data: $e');
    }
  }
}
