class LocationModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final String? placeId;
  final Map<String, dynamic>? metadata;
  final DateTime? timestamp;

  LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.placeId,
    this.metadata,
    this.timestamp,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      address: json['address'],
      placeId: json['placeId'],
      metadata: json['metadata'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'placeId': placeId,
      'metadata': metadata,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  LocationModel copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    String? placeId,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      placeId: placeId ?? this.placeId,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
