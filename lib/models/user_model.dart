class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final Map<String, dynamic> preferences;
  final List<String> favoriteLocations;
  final bool isEmailVerified;
  final String userRole;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.preferences = const {},
    this.favoriteLocations = const [],
    this.isEmailVerified = false,
    this.userRole = 'user',
    required this.createdAt,
    required this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      photoUrl: json['photoUrl'],
      preferences: json['preferences'] ?? {},
      favoriteLocations: List<String>.from(json['favoriteLocations'] ?? []),
      isEmailVerified: json['isEmailVerified'] ?? false,
      userRole: json['userRole'] ?? 'user',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'preferences': preferences,
      'favoriteLocations': favoriteLocations,
      'isEmailVerified': isEmailVerified,
      'userRole': userRole,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    Map<String, dynamic>? preferences,
    List<String>? favoriteLocations,
    bool? isEmailVerified,
    String? userRole,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      preferences: preferences ?? this.preferences,
      favoriteLocations: favoriteLocations ?? this.favoriteLocations,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      userRole: userRole ?? this.userRole,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
