import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/collection_model.dart';

/// REST client for Collections (`/api/collections`, requires token), verified against
/// CollectionsController.
class CollectionApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  String? _bearerToken;
  void setBearerToken(String token) => _bearerToken = token;

  Map<String, String> _headers() {
    final h = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_bearerToken != null && _bearerToken!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_bearerToken';
    }
    return h;
  }

  /// GET /collections/user/{userId}
  Future<List<CollectionModel>> getByUser(int userId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/collections/user/$userId'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((j) => CollectionModel.fromJson(j as Map<String, dynamic>)).toList();
      }
      return [];
    }
    if (response.statusCode == 404) return [];
    throw Exception('Error al cargar colecciones: ${response.statusCode}');
  }

  /// POST /collections
  Future<CollectionModel> create(String name, int fkIdUser) async {
    final response = await http
        .post(Uri.parse('$baseUrl/collections'),
            headers: _headers(), body: json.encode({'name': name, 'fkIdUser': fkIdUser}))
        .timeout(const Duration(seconds: 12));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CollectionModel.fromJson(json.decode(response.body));
    }
    throw Exception('No se pudo crear la colección: ${_message(response)}');
  }

  /// PUT /collections/{id}
  Future<CollectionModel> rename(int id, String name) async {
    final response = await http
        .put(Uri.parse('$baseUrl/collections/$id'),
            headers: _headers(), body: json.encode({'name': name}))
        .timeout(const Duration(seconds: 12));
    if (response.statusCode == 200) {
      return CollectionModel.fromJson(json.decode(response.body));
    }
    throw Exception('No se pudo renombrar la colección: ${response.statusCode}');
  }

  /// DELETE /collections/{id}
  Future<void> delete(int id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/collections/$id'), headers: _headers())
        .timeout(const Duration(seconds: 12));
    if (response.statusCode == 200 || response.statusCode == 204) return;
    throw Exception('No se pudo eliminar la colección: ${response.statusCode}');
  }

  /// POST /collections/{id}/routes/{routeId}
  Future<void> addRoute(int collectionId, int routeId) async {
    final response = await http
        .post(Uri.parse('$baseUrl/collections/$collectionId/routes/$routeId'), headers: _headers())
        .timeout(const Duration(seconds: 12));
    if (response.statusCode == 200 || response.statusCode == 201) return;
    throw Exception('No se pudo agregar la ruta: ${_message(response)}');
  }

  /// DELETE /collections/{id}/routes/{routeId}
  Future<void> removeRoute(int collectionId, int routeId) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/collections/$collectionId/routes/$routeId'), headers: _headers())
        .timeout(const Duration(seconds: 12));
    if (response.statusCode == 200 || response.statusCode == 204) return;
    throw Exception('No se pudo quitar la ruta: ${response.statusCode}');
  }

  /// GET /collections/{id}/routes
  Future<List<CollectionItemModel>> getRoutes(int collectionId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/collections/$collectionId/routes'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((j) => CollectionItemModel.fromJson(j as Map<String, dynamic>)).toList();
      }
      return [];
    }
    if (response.statusCode == 404) return [];
    throw Exception('Error al cargar rutas: ${response.statusCode}');
  }

  String _message(http.Response response) {
    try {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {/* non-JSON */}
    return '${response.statusCode}';
  }
}
