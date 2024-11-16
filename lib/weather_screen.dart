import 'package:flutter/material.dart';
import 'package:weather_app/forecast.dart';
import 'weather_service.dart';
import 'location_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  double temperature = 0.0;
  double precipitation = 0.0;
  String city = '';
  bool isLoading = true;
  String errorMessage = '';

  // Five-day forecast
  late DailyForecast forecast;

  @override
  void initState() {
    super.initState();
    _showMockData();
    _fetchRealLocationWeatherAndForecast();
  }

  void _showMockData() {
    final mockCity = _locationService.getMockCity();
    final mockWeatherData = _weatherService.getMockHourlyWeather();
    final mockForecast = _weatherService.getMockDailyForecast();

    setState(() {
      city = mockCity;
      temperature = mockWeatherData.temperature2m[0];
      precipitation = mockWeatherData.precipitation[0];
      forecast = mockForecast;
    });
  }

  Future<void> _fetchRealLocationWeatherAndForecast() async {
    try {
      final position = await _locationService.determinePosition();
      final cityName = await _locationService.getCityFromCoordinates(
          position.latitude, position.longitude);
      final realWeatherData = await _weatherService.fetchHourlyWeather(
          position.latitude, position.longitude);
      final realForecastData = await _weatherService.fetchDailyForecast(
          position.latitude, position.longitude);

      setState(() {
        city = cityName;
        temperature = realWeatherData.temperature2m.first;
        precipitation = realWeatherData.precipitation.first;
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
                          itemCount: forecast.temperature2mMax.length,
                          itemBuilder: (context, index) {
                            //             final dayForecast = forecast[index];
                            return ListTile(
                                title: const Text("NINO"),
                                subtitle: const Text("data"));
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
