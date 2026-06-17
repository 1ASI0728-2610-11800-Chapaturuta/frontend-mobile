import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    required super.lastName,
    required super.username,
    required super.email,
    required super.phone,
    required super.gender,
    super.favoriteRoutes,
    super.driverId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      favoriteRoutes: List<String>.from(json['favoriteRoutes'] ?? []),
      driverId: _parseInt(json['driverId']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'username': username,
      'email': email,
      'phone': phone,
      'gender': gender,
      'favoriteRoutes': favoriteRoutes,
      'driverId': driverId,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? lastName,
    String? username,
    String? email,
    String? phone,
    String? gender,
    List<String>? favoriteRoutes,
    int? driverId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      favoriteRoutes: favoriteRoutes ?? this.favoriteRoutes,
      driverId: driverId ?? this.driverId,
    );
  }
}
