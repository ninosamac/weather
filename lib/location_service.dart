import 'package:geolocator/geolocator.dart';

class LocationService {
  // Mock location data to display initially
  Position getMockPosition() {
    return Position(
      latitude: 45.0,
      longitude: 16.0,
      timestamp: DateTime.now(),
      accuracy: 1.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }

  // Mock city name to display initially
  String getMockCity() {
    return 'Zagreb';
  }

  // Real location data
  Future<Position> determinePosition() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Reverse geocoding to get city name from coordinates
  Future<String> getCityFromCoordinates(
      double latitude, double longitude) async {
    // For simplicity, use a placeholder as actual reverse geocoding may involve
    // other libraries or APIs (e.g., Google Maps or location APIs).
    return 'Zagreb';
  }

  Future<Position> _getCurrentLocation() async {
    final isLocationServiceEnabled =
        await Geolocator.isLocationServiceEnabled();
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
}
