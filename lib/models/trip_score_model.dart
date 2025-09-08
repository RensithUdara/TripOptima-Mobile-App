class TripScoreModel {
  final String id;
  final String tripId;
  final double overallScore;
  final double weatherScore;
  final double distanceScore;
  final double seasonalScore;
  final double costScore;
  final Map<String, double> categoryScores;
  final String recommendation;
  final List<Map<String, dynamic>> alternativeSuggestions;
  final DateTime createdAt;

  TripScoreModel({
    required this.id,
    required this.tripId,
    required this.overallScore,
    required this.weatherScore,
    required this.distanceScore,
    required this.seasonalScore,
    required this.costScore,
    this.categoryScores = const {},
    required this.recommendation,
    this.alternativeSuggestions = const [],
    required this.createdAt,
  });

  factory TripScoreModel.fromJson(Map<String, dynamic> json) {
    return TripScoreModel(
      id: json['id'] ?? '',
      tripId: json['tripId'] ?? '',
      overallScore: json['overallScore']?.toDouble() ?? 0.0,
      weatherScore: json['weatherScore']?.toDouble() ?? 0.0,
      distanceScore: json['distanceScore']?.toDouble() ?? 0.0,
      seasonalScore: json['seasonalScore']?.toDouble() ?? 0.0,
      costScore: json['costScore']?.toDouble() ?? 0.0,
      categoryScores: _parseCategoryScores(json['categoryScores']),
      recommendation: json['recommendation'] ?? '',
      alternativeSuggestions: _parseAlternatives(json['alternativeSuggestions']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static Map<String, double> _parseCategoryScores(dynamic json) {
    if (json == null) return {};
    Map<String, double> result = {};
    (json as Map).forEach((key, value) {
      result[key.toString()] = (value as num).toDouble();
    });
    return result;
  }

  static List<Map<String, dynamic>> _parseAlternatives(dynamic json) {
    if (json == null) return [];
    return (json as List).map((e) => e as Map<String, dynamic>).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'overallScore': overallScore,
      'weatherScore': weatherScore,
      'distanceScore': distanceScore,
      'seasonalScore': seasonalScore,
      'costScore': costScore,
      'categoryScores': categoryScores,
      'recommendation': recommendation,
      'alternativeSuggestions': alternativeSuggestions,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  TripScoreModel copyWith({
    String? id,
    String? tripId,
    double? overallScore,
    double? weatherScore,
    double? distanceScore,
    double? seasonalScore,
    double? costScore,
    Map<String, double>? categoryScores,
    String? recommendation,
    List<Map<String, dynamic>>? alternativeSuggestions,
    DateTime? createdAt,
  }) {
    return TripScoreModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      overallScore: overallScore ?? this.overallScore,
      weatherScore: weatherScore ?? this.weatherScore,
      distanceScore: distanceScore ?? this.distanceScore,
      seasonalScore: seasonalScore ?? this.seasonalScore,
      costScore: costScore ?? this.costScore,
      categoryScores: categoryScores ?? this.categoryScores,
      recommendation: recommendation ?? this.recommendation,
      alternativeSuggestions: alternativeSuggestions ?? this.alternativeSuggestions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
