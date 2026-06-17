import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  AuthUserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.token,
    super.refreshToken,
    super.role,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? json['username'] ?? '',
      token: json['token'] ?? json['accessToken'] ?? '',
      refreshToken: json['refreshToken'],
      role: _parseRole(json['role'] ?? json['userRole']),
    );
  }

  static int _parseRole(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      switch (value.toLowerCase()) {
        case 'traveller':
          return 0;
        case 'driver':
          return 2;
        case 'admin':
          return 3;
      }
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'token': token,
      'refreshToken': refreshToken,
      'role': role,
    };
  }
}
