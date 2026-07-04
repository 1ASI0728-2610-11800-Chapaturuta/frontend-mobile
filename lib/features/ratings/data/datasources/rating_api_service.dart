import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/rating_model.dart';

/// REST client for Ratings (`/api/ratings`), verified against RatingsController.
class RatingApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  String? _token;
  void setToken(String token) => _token = token;

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// POST /ratings — Traveller/Admin only.
  Future<RatingModel> create({
    required int fkIdUser,
    required int fkIdDriver,
    required int fkIdTrip,
    required int score,
    String? comment,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/ratings'),
          headers: _headers(),
          body: json.encode({
            'fkIdUser': fkIdUser,
            'fkIdDriver': fkIdDriver,
            'fkIdTrip': fkIdTrip,
            'score': score,
            'comment': comment,
          }),
        )
        .timeout(const Duration(seconds: 12));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return RatingModel.fromJson(json.decode(response.body));
    }
    throw Exception('No se pudo enviar la calificación: ${_message(response)}');
  }

  /// GET /ratings/driver/{driverId}
  Future<List<RatingModel>> getByDriver(int driverId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/ratings/driver/$driverId'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((j) => RatingModel.fromJson(j as Map<String, dynamic>)).toList();
      }
      return [];
    }
    if (response.statusCode == 404) return [];
    throw Exception('Error al cargar calificaciones: ${response.statusCode}');
  }

  /// GET /ratings/driver/{driverId}/summary
  Future<RatingSummary?> getDriverSummary(int driverId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/ratings/driver/$driverId/summary'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return RatingSummary.fromJson(json.decode(response.body));
    }
    if (response.statusCode == 404) return null;
    throw Exception('Error al cargar el resumen: ${response.statusCode}');
  }

  /// GET /ratings/user/{userId}
  Future<List<RatingModel>> getByUser(int userId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/ratings/user/$userId'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((j) => RatingModel.fromJson(j as Map<String, dynamic>)).toList();
      }
      return [];
    }
    if (response.statusCode == 404) return [];
    throw Exception('Error al cargar calificaciones: ${response.statusCode}');
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
