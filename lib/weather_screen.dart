import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'forecast.dart';
import 'weather_service.dart';
import 'weather.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();

  // Default location (e.g., Zagreb)
  static const double _defaultLatitude = 45.8150;
  static const double _defaultLongitude = 15.9819;

  // Mock data for initial display
  HourlyWeather? _hourlyWeather = WeatherService().getMockHourlyWeather();
  DailyForecast? _dailyForecast = WeatherService().getMockDailyForecast();

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeatherDataWithLocation();
  }

  Future<void> _fetchWeatherDataWithLocation() async {
    try {
      final position = await _getCurrentLocation();
      await _fetchWeatherData(position.latitude, position.longitude);
    } catch (e) {
      // If location access fails, use the default location
      await _fetchWeatherData(_defaultLatitude, _defaultLongitude);
    }
  }

  Future<Position> _getCurrentLocation() async {
    // Check location permission
    final isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    // Fetch the current location
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    try {
      final hourlyWeather = await _weatherService.fetchHourlyWeather(latitude, longitude);
      final dailyForecast = await _weatherService.fetchDailyForecast(latitude, longitude);

      setState(() {
        _hourlyWeather = hourlyWeather;
        _dailyForecast = dailyForecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch weather data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _buildWeatherContent(),
    );
  }

  Widget _buildWeatherContent() {
    if (_hourlyWeather == null || _dailyForecast == null) {
      return const Center(child: Text('No weather data available.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Weather',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8.0),
          Card(
            child: ListTile(
              title: Text('Temperature: ${_hourlyWeather!.temperature2m.first}°C'),
              subtitle: Text('Precipitation: ${_hourlyWeather!.precipitation.first} mm'),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            '5-Day Forecast',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8.0),
          ..._dailyForecast!.temperature2mMax.asMap().entries.map((entry) {
            final index = entry.key;
            final temperature = entry.value;
            final precipitation = _dailyForecast!.precipitationSum[index];
            return Card(
              child: ListTile(
                title: Text('Day ${index + 1}'),
                subtitle: Text(
                  'Max Temp: ${temperature}°C, Precipitation: ${precipitation} mm',
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
