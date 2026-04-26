import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/route_model.dart';

class RouteApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  String? _bearerToken;

  void setBearerToken(String token) {
    _bearerToken = token;
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_bearerToken != null && _bearerToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_bearerToken';
    }
    return headers;
  }

  Future<List<TransportRouteModel>> getAllRoutes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/routes'),
      headers: _getHeaders(),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Timeout: El servidor no respondió a tiempo'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((j) => TransportRouteModel.fromJson(j)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado. Token inválido o expirado');
    } else if (response.statusCode == 404) {
      throw Exception('Endpoint /routes no encontrado en el servidor');
    } else {
      throw Exception('Error al cargar rutas: ${response.statusCode}');
    }
  }

  Future<TransportRouteModel?> getRouteById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/routes/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return TransportRouteModel.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado. Token inválido o expirado');
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al cargar ruta: ${response.statusCode}');
    }
  }

  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/routes'),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }
}
