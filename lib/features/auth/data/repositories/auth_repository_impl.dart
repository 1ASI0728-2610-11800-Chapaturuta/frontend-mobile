import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_service.dart';
import '../models/auth_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService apiService;
  static const String _authKey = 'auth_user';

  AuthRepositoryImpl({required this.apiService});

  @override
  Future<AuthUser> login(String email, String password) async {
    final user = await apiService.login(email, password);
    await saveUser(user);
    return user;
  }

  @override
  Future<AuthUser> register(String email, String password, String name) async {
    final user = await apiService.register(
      email: email,
      password: password,
      name: name,
    );
    await saveUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_authKey);
    
    if (userJson != null) {
      final userData = json.decode(userJson);
      final user = AuthUserModel.fromJson(userData);
      await apiService.logout(user.token);
    }
    
    await prefs.remove(_authKey);
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_authKey);
      
      if (userJson != null) {
        final userData = json.decode(userJson);
        return AuthUserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveUser(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final userModel = AuthUserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      token: user.token,
      refreshToken: user.refreshToken,
    );
    await prefs.setString(_authKey, json.encode(userModel.toJson()));
  }
}