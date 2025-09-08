import 'package:trip_optima_mobile_app/models/location_model.dart';

enum TripStatus { planned, active, completed, cancelled }

enum TripVisibility { private, shared, public }

class TripModel {
  final String id;
  final String name;
  final String userId;
  final String description;
  final LocationModel startLocation;
  final List<LocationModel> destinations;
  final DateTime startDate;
  final DateTime? endDate;
  final TripStatus status;
  final TripVisibility visibility;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final double? tripScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  TripModel({
    required this.id,
    required this.name,
    required this.userId,
    this.description = '',
    required this.startLocation,
    required this.destinations,
    required this.startDate,
    this.endDate,
    this.status = TripStatus.planned,
    this.visibility = TripVisibility.private,
    this.tags = const [],
    this.metadata = const {},
    this.tripScore,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userId: json['userId'] ?? '',
      description: json['description'] ?? '',
      startLocation: LocationModel.fromJson(json['startLocation'] ?? {}),
      destinations: (json['destinations'] as List?)
          ?.map((e) => LocationModel.fromJson(e))
          .toList() ??
          [],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate:
          json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      status: _parseStatus(json['status']),
      visibility: _parseVisibility(json['visibility']),
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata'] ?? {},
      tripScore: json['tripScore']?.toDouble(),
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
      'name': name,
      'userId': userId,
      'description': description,
      'startLocation': startLocation.toJson(),
      'destinations': destinations.map((loc) => loc.toJson()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status.toString().split('.').last,
      'visibility': visibility.toString().split('.').last,
      'tags': tags,
      'metadata': metadata,
      'tripScore': tripScore,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static TripStatus _parseStatus(String? status) {
    switch (status) {
      case 'planned':
        return TripStatus.planned;
      case 'active':
        return TripStatus.active;
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      default:
        return TripStatus.planned;
    }
  }

  static TripVisibility _parseVisibility(String? visibility) {
    switch (visibility) {
      case 'private':
        return TripVisibility.private;
      case 'shared':
        return TripVisibility.shared;
      case 'public':
        return TripVisibility.public;
      default:
        return TripVisibility.private;
    }
  }

  TripModel copyWith({
    String? id,
    String? name,
    String? userId,
    String? description,
    LocationModel? startLocation,
    List<LocationModel>? destinations,
    DateTime? startDate,
    DateTime? endDate,
    TripStatus? status,
    TripVisibility? visibility,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    double? tripScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      startLocation: startLocation ?? this.startLocation,
      destinations: destinations ?? this.destinations,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      tripScore: tripScore ?? this.tripScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
