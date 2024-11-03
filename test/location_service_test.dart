import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/location_service.dart';

class MockLocationService extends LocationService {
  bool throwError = false;
  Position mockPosition = Position(
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

  @override
  Future<Position> determinePosition() async {
    if (throwError) {
      throw Exception('Mock location error');
    }
    return mockPosition;
  }

  @override
  Future<String> getCityFromCoordinates(
      double latitude, double longitude) async {
    if (throwError) {
      throw Exception('Mock geocoding error');
    }
    return 'Zagreb';
  }
}

void main() {
  group('LocationService', () {
    final locationService = MockLocationService();

    test('determinePosition returns position when successful', () async {
      final position = await locationService.determinePosition();

      expect(position.latitude, 45.0);
      expect(position.longitude, 16.0);
    });

    test('determinePosition throws an exception on failure', () async {
      locationService.throwError = true;

      expect(() async => await locationService.determinePosition(),
          throwsA(isA<Exception>()));
    });

    test('getCityFromCoordinates returns city when successful', () async {
      final city = await locationService.getCityFromCoordinates(45.0, 16.0);

      expect(city, 'Zagreb');
    });

    test('getCityFromCoordinates throws an exception on failure', () async {
      locationService.throwError = true;

      expect(
          () async => await locationService.getCityFromCoordinates(45.0, 16.0),
          throwsA(isA<Exception>()));
    });
  });
}
