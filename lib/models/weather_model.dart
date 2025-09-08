import 'package:trip_optima_mobile_app/models/location_model.dart';

class WeatherModel {
  final String id;
  final String locationId;
  final DateTime timestamp;
  final String condition;
  final String description;
  final String icon;
  final double temperature; // in Celsius
  final double feelsLike;
  final double minTemp;
  final double maxTemp;
  final double windSpeed;
  final double windDirection;
  final double humidity;
  final double rain;
  final double snow;
  final double visibility;
  final double clouds;
  final double pressure;

  WeatherModel({
    required this.id,
    required this.location,
    required this.timestamp,
    required this.condition,
    required this.temperature,
    required this.feelsLike,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    required this.precipitation,
    required this.visibility,
    required this.uvIndex,
    required this.pressure,
    required this.cloudCover,
    required this.sunrise,
    required this.sunset,
    this.alerts = const {},
    this.hourlyForecast = const {},
    this.dailyForecast = const {},
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      id: json['id'] ?? '',
      location: LocationModel.fromJson(json['location'] ?? {}),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      condition: json['condition'] ?? 'Unknown',
      temperature: json['temperature']?.toDouble() ?? 0.0,
      feelsLike: json['feelsLike']?.toDouble() ?? 0.0,
      windSpeed: json['windSpeed']?.toDouble() ?? 0.0,
      windDirection: json['windDirection'] ?? 0,
      humidity: json['humidity']?.toDouble() ?? 0.0,
      precipitation: json['precipitation']?.toDouble() ?? 0.0,
      visibility: json['visibility']?.toDouble() ?? 0.0,
      uvIndex: json['uvIndex']?.toDouble() ?? 0.0,
      pressure: json['pressure']?.toDouble() ?? 0.0,
      cloudCover: json['cloudCover'] ?? 0,
      sunrise: json['sunrise'] != null
          ? DateTime.parse(json['sunrise'])
          : DateTime.now(),
      sunset: json['sunset'] != null
          ? DateTime.parse(json['sunset'])
          : DateTime.now(),
      alerts: json['alerts'] ?? {},
      hourlyForecast: json['hourlyForecast'] ?? {},
      dailyForecast: json['dailyForecast'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'condition': condition,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'humidity': humidity,
      'precipitation': precipitation,
      'visibility': visibility,
      'uvIndex': uvIndex,
      'pressure': pressure,
      'cloudCover': cloudCover,
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
      'alerts': alerts,
      'hourlyForecast': hourlyForecast,
      'dailyForecast': dailyForecast,
    };
  }

  WeatherModel copyWith({
    String? id,
    LocationModel? location,
    DateTime? timestamp,
    String? condition,
    double? temperature,
    double? feelsLike,
    double? windSpeed,
    int? windDirection,
    double? humidity,
    double? precipitation,
    double? visibility,
    double? uvIndex,
    double? pressure,
    int? cloudCover,
    DateTime? sunrise,
    DateTime? sunset,
    Map<String, dynamic>? alerts,
    Map<String, dynamic>? hourlyForecast,
    Map<String, dynamic>? dailyForecast,
  }) {
    return WeatherModel(
      id: id ?? this.id,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      condition: condition ?? this.condition,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
      humidity: humidity ?? this.humidity,
      precipitation: precipitation ?? this.precipitation,
      visibility: visibility ?? this.visibility,
      uvIndex: uvIndex ?? this.uvIndex,
      pressure: pressure ?? this.pressure,
      cloudCover: cloudCover ?? this.cloudCover,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      alerts: alerts ?? this.alerts,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
      dailyForecast: dailyForecast ?? this.dailyForecast,
    );
  }
}
