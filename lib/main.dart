import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // Weather data
  String temperature = '';
  String precipitation = '';
  String city = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    determinePosition().then((Position position) {
      fetchCityName(position.latitude, position.longitude);
      fetchWeatherData(position.latitude, position.longitude);
    });
  }

  Future<void> fetchWeatherData(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,precipitation&timezone=auto');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperature = data['hourly']['temperature_2m'][0].toString();
          precipitation = data['hourly']['precipitation'][0].toString();
          isLoading = false;
        });
      } else {
        setState(() {
          temperature = 'Error fetching temperature';
          precipitation = 'Error fetching precipitation';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        temperature = 'Failed to load data';
        precipitation = 'Failed to load data';
        isLoading = false;
      });
    }
  }

  Future<void> fetchCityName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      setState(() {
        city = placemarks[0].locality ?? 'Unknown location';
      });
    } catch (e) {
      setState(() {
        city = 'Failed to get city';
      });
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permission.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get current location.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'City: $city',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Temperature: $temperature°C',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Precipitation: $precipitation mm',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
      ),
    );
  }
}
