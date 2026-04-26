import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/trip_model.dart';

// TODO: endpoint pendiente de implementación en backend (/api/trips)
class TripApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  String? _token;
  void setToken(String token) => _token = token;

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<List<TripModel>> getMyTrips() async {
    final response = await http.get(
      Uri.parse('$baseUrl/trips/my'),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => TripModel.fromJson(j)).toList();
    }
    throw Exception('Error al cargar viajes: ${response.statusCode}');
  }
}
