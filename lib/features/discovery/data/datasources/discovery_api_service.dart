import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../routes/data/models/route_model.dart';
import '../models/nearby_stop_model.dart';
import '../models/search_result_model.dart';

/// Thrown when the backend rejects a Discovery call because the user's Free-plan
/// quota is exhausted (HTTP 403). Callers surface an upgrade hint.
class DiscoveryQuotaException implements Exception {
  final String message;
  DiscoveryQuotaException(this.message);
  @override
  String toString() => message;
}

/// REST client for Discovery (`/api/discovery`). Every read needs `userId` because the
/// backend meters Discovery usage against the user's plan quota.
class DiscoveryApiService {
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

  /// GET /discovery/search?userId=&origin=&destination=&date=
  Future<List<SearchResultModel>> search({
    required int userId,
    String? origin,
    String? destination,
    String? date,
  }) async {
    final params = <String, String>{'userId': '$userId'};
    if (origin != null && origin.isNotEmpty) params['origin'] = origin;
    if (destination != null && destination.isNotEmpty) params['destination'] = destination;
    if (date != null && date.isNotEmpty) params['date'] = date;

    final uri = Uri.parse('$baseUrl/discovery/search').replace(queryParameters: params);
    final response = await http.get(uri, headers: _headers()).timeout(const Duration(seconds: 20));
    final data = _decodeList(response, 'No se pudieron buscar rutas');
    return data.map((j) => SearchResultModel.fromJson(j)).toList();
  }

  /// GET /discovery/popular?userId=&limit=
  Future<List<TransportRouteModel>> popular({required int userId, int limit = 10}) async {
    final uri = Uri.parse('$baseUrl/discovery/popular')
        .replace(queryParameters: {'userId': '$userId', 'limit': '$limit'});
    final response = await http.get(uri, headers: _headers()).timeout(const Duration(seconds: 15));
    final data = _decodeList(response, 'No se pudieron cargar rutas populares');
    return data.map((j) => TransportRouteModel.fromJson(j)).toList();
  }

  /// GET /discovery/nearby?userId=&lat=&lng=&radius=&useRoadDistance=
  Future<List<NearbyStopModel>> nearby({
    required int userId,
    required double lat,
    required double lng,
    double radius = 2.0,
    bool useRoadDistance = false,
  }) async {
    final uri = Uri.parse('$baseUrl/discovery/nearby').replace(queryParameters: {
      'userId': '$userId',
      'lat': '$lat',
      'lng': '$lng',
      'radius': '$radius',
      'useRoadDistance': '$useRoadDistance',
    });
    final response = await http.get(uri, headers: _headers()).timeout(const Duration(seconds: 15));
    final data = _decodeList(response, 'No se pudieron cargar paraderos cercanos');
    return data.map((j) => NearbyStopModel.fromJson(j)).toList();
  }

  List<Map<String, dynamic>> _decodeList(http.Response response, String errorMsg) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) return data.cast<Map<String, dynamic>>();
      return const [];
    }
    if (response.statusCode == 403) {
      throw DiscoveryQuotaException(_message(response,
          'Alcanzaste el límite de búsquedas de tu plan. Actualiza a Premium para búsquedas ilimitadas.'));
    }
    throw Exception('$errorMsg (${response.statusCode})');
  }

  String _message(http.Response response, String fallback) {
    try {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {/* non-JSON */}
    return fallback;
  }
}
