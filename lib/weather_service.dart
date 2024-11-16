import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/DailyForecast.dart';
import 'package:weather_app/HourlyWeather.dart';

class WeatherService {
  // Mock data for testing purposes
  HourlyWeather getMockHourlyWeather() {
    return HourlyWeather(
      latitude: 45.0,
      longitude: 16.0,
      generationTimeMs: 10.3,
      utcOffsetSeconds: 7200,
      timezone: "Europe/Zagreb",
      timezoneAbbreviation: "CEST",
      temperature2m: [22.5, 23.0, 24.0],
      precipitation: [0.0, 0.1, 0.2],
    );
  }

  DailyForecast getMockDailyForecast() {
    return DailyForecast(
      latitude: 45.0,
      longitude: 16.0,
      generationTimeMs: 10.3,
      utcOffsetSeconds: 7200,
      timezone: "Europe/Zagreb",
      timezoneAbbreviation: "CEST",
      temperature2mMax: [23.0, 24.0, 22.5, 21.0, 20.0],
      precipitationSum: [0.0, 0.1, 0.5, 1.0, 0.2],
    );
  }

  // Fetch real-time hourly weather data
  Future<HourlyWeather> fetchHourlyWeather(
      double latitude, double longitude) async {
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,precipitation&timezone=auto');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return HourlyWeather.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch hourly weather data');
    }
  }

  // Fetch real-time daily forecast data
  Future<DailyForecast> fetchDailyForecast(
      double latitude, double longitude) async {
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=temperature_2m_max,precipitation_sum&timezone=auto');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return DailyForecast.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch daily forecast data');
    }
  }
}
