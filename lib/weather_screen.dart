import 'package:flutter/material.dart';
import 'weather_service.dart';
import 'location_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  String temperature = '';
  String precipitation = '';
  String city = '';
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _showMockData();
    _fetchRealLocationAndWeather();
  }

  void _showMockData() {
    final mockPosition = _locationService.getMockPosition();
    final mockCity = _locationService.getMockCity();
    final mockWeatherData = _weatherService.getMockWeatherData();

    setState(() {
      city = mockCity;
      temperature = mockWeatherData['temperature'];
      precipitation = mockWeatherData['precipitation'];
    });
  }

  Future<void> _fetchRealLocationAndWeather() async {
    try {
      final position = await _locationService.determinePosition();
      final cityName = await _locationService.getCityFromCoordinates(
          position.latitude, position.longitude);
      final realWeatherData = await _weatherService.fetchWeatherData(
          position.latitude, position.longitude);

      setState(() {
        city = cityName;
        temperature = realWeatherData['temperature'];
        precipitation = realWeatherData['precipitation'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Center(
        child: isLoading && errorMessage.isEmpty
            ? const CircularProgressIndicator()
            : errorMessage.isNotEmpty
                ? Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('City: $city', style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 20),
                      Text('Temperature: $temperature°C',
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 20),
                      Text('Precipitation: $precipitation mm',
                          style: const TextStyle(fontSize: 20)),
                    ],
                  ),
      ),
    );
  }
}
