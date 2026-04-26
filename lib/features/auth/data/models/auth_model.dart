import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  AuthUserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.token,
    super.refreshToken,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? json['username'] ?? '',
      token: json['token'] ?? json['accessToken'] ?? '',
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'token': token,
      'refreshToken': refreshToken,
    };
  }
}