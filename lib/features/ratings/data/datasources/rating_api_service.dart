import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/rating_model.dart';

// TODO: endpoint pendiente de implementación en backend (/api/ratings)
class RatingApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  String? _token;
  void setToken(String token) => _token = token;

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<List<RatingModel>> getRatingsForRoute(int routeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/ratings?routeId=$routeId'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => RatingModel.fromJson(j)).toList();
    }
    throw Exception('Error al cargar calificaciones: ${response.statusCode}');
  }

  Future<RatingModel> createRating({
    required int routeId,
    required double score,
    String? comment,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ratings'),
      headers: _headers(),
      body: json.encode({'routeId': routeId, 'score': score, 'comment': comment}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return RatingModel.fromJson(json.decode(response.body));
    }
    throw Exception('Error al crear calificación: ${response.statusCode}');
  }
}
