import 'package:trip_optima_mobile_app/models/location_model.dart';

class RouteModel {
  final String id;
  final String tripId;
  final List<LocationModel> waypoints;
  final List<List<dynamic>> polylinePoints;
  final double totalDistance; // in meters
  final int totalDuration; // in seconds
  final Map<String, dynamic> trafficInfo;
  final List<Map<String, dynamic>> legs;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  RouteModel({
    required this.id,
    required this.tripId,
    required this.waypoints,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
    this.trafficInfo = const {},
    this.legs = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] ?? '',
      tripId: json['tripId'] ?? '',
      waypoints: (json['waypoints'] as List?)
          ?.map((e) => LocationModel.fromJson(e))
          .toList() ??
          [],
      polylinePoints: (json['polylinePoints'] as List?)
          ?.map((e) => (e as List).map((p) => p).toList())
          .toList() ??
          [],
      totalDistance: json['totalDistance']?.toDouble() ?? 0.0,
      totalDuration: json['totalDuration'] ?? 0,
      trafficInfo: json['trafficInfo'] ?? {},
      legs: (json['legs'] as List?)?.map((e) => e as Map<String, dynamic>).toList() ?? [],
      metadata: json['metadata'] ?? {},
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'waypoints': waypoints.map((wp) => wp.toJson()).toList(),
      'polylinePoints': polylinePoints,
      'totalDistance': totalDistance,
      'totalDuration': totalDuration,
      'trafficInfo': trafficInfo,
      'legs': legs,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  RouteModel copyWith({
    String? id,
    String? tripId,
    List<LocationModel>? waypoints,
    List<List<dynamic>>? polylinePoints,
    double? totalDistance,
    int? totalDuration,
    Map<String, dynamic>? trafficInfo,
    List<Map<String, dynamic>>? legs,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RouteModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      waypoints: waypoints ?? this.waypoints,
      polylinePoints: polylinePoints ?? this.polylinePoints,
      totalDistance: totalDistance ?? this.totalDistance,
      totalDuration: totalDuration ?? this.totalDuration,
      trafficInfo: trafficInfo ?? this.trafficInfo,
      legs: legs ?? this.legs,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
