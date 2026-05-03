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
  Future<AuthUser> register(String email, String password, String name, {int role = 0}) async {
    // sign-up backend solo retorna {message}: no incluye token/id/role.
    // Hacemos login automatico para obtener una sesion completa.
    await apiService.register(
      email: email,
      password: password,
      name: name,
      role: role,
    );
    final user = await apiService.login(email, password);
    final enriched = AuthUserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      token: user.token,
      refreshToken: user.refreshToken,
      role: user.role == 0 ? role : user.role,
    );
    await saveUser(enriched);
    return enriched;
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
      role: user.role,
    );
    await prefs.setString(_authKey, json.encode(userModel.toJson()));
  }
}
