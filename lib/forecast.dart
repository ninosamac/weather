class DailyForecast {
  final double latitude;
  final double longitude;
  final double generationTimeMs;
  final int utcOffsetSeconds;
  final String timezone;
  final String timezoneAbbreviation;
  final List<double> temperature2mMax;
  final List<double> precipitationSum;

  DailyForecast({
    required this.latitude,
    required this.longitude,
    required this.generationTimeMs,
    required this.utcOffsetSeconds,
    required this.timezone,
    required this.timezoneAbbreviation,
    required this.temperature2mMax,
    required this.precipitationSum,
  });

  // Factory method for JSON parsing
  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      latitude: json['latitude'],
      longitude: json['longitude'],
      generationTimeMs: json['generationtime_ms'],
      utcOffsetSeconds: json['utc_offset_seconds'],
      timezone: json['timezone'],
      timezoneAbbreviation: json['timezone_abbreviation'],
      temperature2mMax: List<double>.from(json['daily']['temperature_2m_max']),
      precipitationSum: List<double>.from(json['daily']['precipitation_sum']),
    );
  }
}
