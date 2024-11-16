class HourlyWeather {
  final double latitude;
  final double longitude;
  final double generationTimeMs;
  final int utcOffsetSeconds;
  final String timezone;
  final String timezoneAbbreviation;
  final List<double> temperature2m;
  final List<double> precipitation;

  HourlyWeather({
    required this.latitude,
    required this.longitude,
    required this.generationTimeMs,
    required this.utcOffsetSeconds,
    required this.timezone,
    required this.timezoneAbbreviation,
    required this.temperature2m,
    required this.precipitation,
  });

  // Factory method for JSON parsing
  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      latitude: json['latitude'],
      longitude: json['longitude'],
      generationTimeMs: json['generationtime_ms'],
      utcOffsetSeconds: json['utc_offset_seconds'],
      timezone: json['timezone'],
      timezoneAbbreviation: json['timezone_abbreviation'],
      temperature2m: List<double>.from(json['hourly']['temperature_2m']),
      precipitation: List<double>.from(json['hourly']['precipitation']),
    );
  }
}