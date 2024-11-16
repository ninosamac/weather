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

  // Five-day forecast
  List<Map<String, String>> forecast = [];

  @override
  void initState() {
    super.initState();
    _showMockData();
    _fetchRealLocationWeatherAndForecast();
  }

  void _showMockData() {
    final mockPosition = _locationService.getMockPosition();
    final mockCity = _locationService.getMockCity();
    final mockWeatherData = _weatherService.getMockWeatherData();
    final mockForecast = _weatherService.getMockForecastData();

    setState(() {
      city = mockCity;
      temperature = mockWeatherData['temperature'];
      precipitation = mockWeatherData['precipitation'];
      forecast = mockForecast;
    });
  }

  Future<void> _fetchRealLocationWeatherAndForecast() async {
    try {
      final position = await _locationService.determinePosition();
      final cityName = await _locationService.getCityFromCoordinates(
          position.latitude, position.longitude);
      final realWeatherData = await _weatherService.fetchWeatherData(
          position.latitude, position.longitude);
      final realForecastData = await _weatherService.fetchForecastData(
          position.latitude, position.longitude);

      setState(() {
        city = cityName;
        temperature = realWeatherData['temperature'];
        precipitation = realWeatherData['precipitation'];
        forecast = realForecastData;
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
                      const SizedBox(height: 20),
                      const Text('5-Day Forecast:',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: forecast.length,
                          itemBuilder: (context, index) {
                            final dayForecast = forecast[index];
                            return ListTile(
                              title: Text(dayForecast['day']!),
                              subtitle: Text(
                                  'Temperature: ${dayForecast['temperature']}°C, Precipitation: ${dayForecast['precipitation']} mm'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
