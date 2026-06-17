import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/auth_model.dart';

class AuthApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  Future<AuthUserModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/authentication/sign-in'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return AuthUserModel.fromJson(jsonData);
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        throw Exception('Credenciales inválidas');
      } else {
        throw Exception('Error en el inicio de sesión: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<AuthUserModel> register({
    required String email,
    required String password,
    required String name,
    int role = 0, // 0=Traveller, 2=Driver, 3=Admin
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/authentication/sign-up'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return AuthUserModel.fromJson(jsonData);
      } else {
        throw Exception('Error en el registro: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> logout(String token) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/authentication/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      // Ignorar errores de logout
    }
  }
}