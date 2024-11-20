import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import 'forecast.dart';
import 'weather_service.dart';
import 'weather.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();

  // Default location (e.g., Zagreb)
  static const double _defaultLatitude = 45.8150;
  static const double _defaultLongitude = 15.9819;
  static const String _defaultCity = "Zagreb";

  // State variables
  HourlyWeather? _hourlyWeather = WeatherService().getMockHourlyWeather();
  DailyForecast? _dailyForecast = WeatherService().getMockDailyForecast();
  String _cityName = _defaultCity;
  DateTime? _currentDateTime;
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
      await _fetchCityName(position.latitude, position.longitude);
    } catch (e) {
      // If location access fails, use the default location and city
      await _fetchWeatherData(_defaultLatitude, _defaultLongitude);
      _cityName = _defaultCity;
    }
  }

  Future<Position> _getCurrentLocation() async {
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

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    try {
      final hourlyWeather = await _weatherService.fetchHourlyWeather(latitude, longitude);
      final dailyForecast = await _weatherService.fetchDailyForecast(latitude, longitude);

      setState(() {
        _hourlyWeather = hourlyWeather;
        _dailyForecast = dailyForecast;

        // Calculate the current time based on the fetched timezone
        final offsetSeconds = hourlyWeather.utcOffsetSeconds;
        _currentDateTime = DateTime.now().toUtc().add(Duration(seconds: offsetSeconds));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch weather data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCityName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          _cityName = placemarks.first.locality ?? _defaultCity;
        });
      }
    } catch (e) {
      setState(() {
        _cityName = _defaultCity;
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
    if (_hourlyWeather == null || _dailyForecast == null || _currentDateTime == null) {
      return const Center(child: Text('No weather data available.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather in $_cityName',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Current Date & Time: ${DateFormat.yMMMMEEEEd().add_Hms().format(_currentDateTime!)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(height: 20.0),
          Text(
            'Current Weather',
            style: Theme.of(context).textTheme.titleLarge,
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
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          ..._dailyForecast!.temperature2mMax.asMap().entries.map((entry) {
            final index = entry.key;
            final temperature = entry.value;
            final precipitation = _dailyForecast!.precipitationSum[index];
            return Card(
              child: ListTile(
                leading: BoxedIcon(
                    getWeatherIcon(temperature, precipitation),
                    size: 40.0
                ),
                title: Text('Day ${index + 1}'),
                subtitle: Text(
                  'Max Temp: $temperature°C, Precipitation: $precipitation mm',
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData getWeatherIcon(double temperature, double precipitation) {return Icons.icecream;}
}
