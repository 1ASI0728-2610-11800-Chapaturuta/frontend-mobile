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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      lastName: json['lastName'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      favoriteRoutes: List<String>.from(json['favoriteRoutes'] ?? []),
    );
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
    );
  }
}