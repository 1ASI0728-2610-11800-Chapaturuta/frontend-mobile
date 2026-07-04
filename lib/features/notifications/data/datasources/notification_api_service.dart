import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/notification_model.dart';

/// REST client for Notifications (`/api/notifications`, requires token), verified
/// against NotificationsController.
class NotificationApiService {
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

  /// GET /notifications/user/{userId}
  Future<List<NotificationModel>> getByUser(int userId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/notifications/user/$userId'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((j) => NotificationModel.fromJson(j as Map<String, dynamic>)).toList();
      }
      return [];
    }
    if (response.statusCode == 404) return [];
    throw Exception('Error al cargar notificaciones: ${response.statusCode}');
  }

  /// PUT /notifications/{id}/read
  Future<NotificationModel> markAsRead(int id) async {
    final response = await http
        .put(Uri.parse('$baseUrl/notifications/$id/read'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return NotificationModel.fromJson(json.decode(response.body));
    }
    throw Exception('No se pudo marcar como leída: ${response.statusCode}');
  }

  /// DELETE /notifications/{id}
  Future<void> delete(int id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/notifications/$id'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200 || response.statusCode == 204) return;
    throw Exception('No se pudo eliminar: ${response.statusCode}');
  }
}
