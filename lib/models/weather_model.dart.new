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
  final double pressure;
  final double visibility;
  final double clouds;
  final double rain;
  final double snow;

  WeatherModel({
    required this.id,
    required this.locationId,
    required this.timestamp,
    required this.condition,
    required this.description,
    required this.icon,
    required this.temperature,
    required this.feelsLike,
    required this.minTemp,
    required this.maxTemp,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    required this.pressure,
    required this.visibility,
    required this.clouds,
    required this.rain,
    required this.snow,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      id: json['id'] ?? '',
      locationId: json['locationId'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      condition: json['condition'] ?? 'Unknown',
      description: json['description'] ?? 'No description available',
      icon: json['icon'] ?? '',
      temperature: json['temperature']?.toDouble() ?? 0.0,
      feelsLike: json['feelsLike']?.toDouble() ?? 0.0,
      minTemp: json['minTemp']?.toDouble() ?? 0.0,
      maxTemp: json['maxTemp']?.toDouble() ?? 0.0,
      windSpeed: json['windSpeed']?.toDouble() ?? 0.0,
      windDirection: json['windDirection']?.toDouble() ?? 0.0,
      humidity: json['humidity']?.toDouble() ?? 0.0,
      pressure: json['pressure']?.toDouble() ?? 0.0,
      visibility: json['visibility']?.toDouble() ?? 0.0,
      clouds: json['clouds']?.toDouble() ?? 0.0,
      rain: json['rain']?.toDouble() ?? 0.0,
      snow: json['snow']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locationId': locationId,
      'timestamp': timestamp.toIso8601String(),
      'condition': condition,
      'description': description,
      'icon': icon,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'humidity': humidity,
      'pressure': pressure,
      'visibility': visibility,
      'clouds': clouds,
      'rain': rain,
      'snow': snow,
    };
  }

  WeatherModel copyWith({
    String? id,
    String? locationId,
    DateTime? timestamp,
    String? condition,
    String? description,
    String? icon,
    double? temperature,
    double? feelsLike,
    double? minTemp,
    double? maxTemp,
    double? windSpeed,
    double? windDirection,
    double? humidity,
    double? pressure,
    double? visibility,
    double? clouds,
    double? rain,
    double? snow,
  }) {
    return WeatherModel(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      timestamp: timestamp ?? this.timestamp,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      minTemp: minTemp ?? this.minTemp,
      maxTemp: maxTemp ?? this.maxTemp,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
      humidity: humidity ?? this.humidity,
      pressure: pressure ?? this.pressure,
      visibility: visibility ?? this.visibility,
      clouds: clouds ?? this.clouds,
      rain: rain ?? this.rain,
      snow: snow ?? this.snow,
    );
  }
}
