import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../../core/config/api_config.dart';
import '../models/company_route_model.dart';

class CompanyRouteApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  String? _bearerToken;
  String? _tileUrl;

  void setBearerToken(String token) {
    _bearerToken = token;
  }

  Map<String, String> _headers() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_bearerToken != null && _bearerToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_bearerToken';
    }
    return headers;
  }

  Future<List<CompanyRouteModel>> getRoutes(int companyId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/routes/company/$companyId'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) return data.map((j) => CompanyRouteModel.fromJson(j)).toList();
      if (data is Map<String, dynamic> && data['items'] is List) {
        return (data['items'] as List).map((j) => CompanyRouteModel.fromJson(j)).toList();
      }
      return [];
    }
    throw Exception('Error al cargar rutas: ${response.statusCode}');
  }

  Future<CompanyRouteModel> createRoute(CompanyRouteModel route) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/routes'),
          headers: _headers(),
          body: json.encode(route.toCreateJson()),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CompanyRouteModel.fromJson(json.decode(response.body));
    }
    throw Exception('Error al crear ruta: ${response.statusCode}');
  }

  Future<CompanyRouteModel> updateRoute(CompanyRouteModel route) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/routes/${route.id}'),
          headers: _headers(),
          body: json.encode(route.toCreateJson()),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return CompanyRouteModel.fromJson(json.decode(response.body));
    }
    if (response.statusCode == 204) return route;
    throw Exception('Error al actualizar ruta: ${response.statusCode}');
  }

  Future<void> deleteRoute(int id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/routes/$id'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200 || response.statusCode == 204) return;
    throw Exception('Error al eliminar ruta: ${response.statusCode}');
  }

  /// Devuelve el payload crudo del endpoint geometry (string encoded, mapa o lista).
  Future<dynamic> getGeometry(int id) async {
    final response = await http
        .get(Uri.parse('$baseUrl/routes/$id/geometry'), headers: _headers())
        .timeout(const Duration(seconds: 12));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic>) {
        return data['geometry'] ?? data['polyline'] ?? data['polylineRoute'] ?? data;
      }
      return data;
    }
    return null;
  }

  Future<String> getMapTileUrl() async {
    if (_tileUrl != null) return _tileUrl!;
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/config/map'), headers: _headers())
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final url = data['tileUrl'] ?? data['tileURL'] ?? data['url'];
        if (url is String && url.isNotEmpty) {
          _tileUrl = url;
          return url;
        }
      }
    } catch (_) {
      // fallback below
    }
    _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    return _tileUrl!;
  }
}
