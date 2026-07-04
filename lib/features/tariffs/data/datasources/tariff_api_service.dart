import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/tariff_model.dart';

/// REST client for the driver Tariffs (`/api/v1/tariffs`), verified against TariffsController.
class TariffApiService {
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

  /// Active tariff for a driver, or null when none exists yet (404). GET /by-driver/{driverId}
  Future<TariffModel?> getByDriver(int driverId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/v1/tariffs/by-driver/$driverId'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final body = response.body.trim();
      if (body.isEmpty || body == 'null') return null;
      return TariffModel.fromJson(json.decode(body));
    }
    if (response.statusCode == 404) return null;
    throw Exception('Error al cargar la tarifa: ${response.statusCode}');
  }

  /// POST /v1/tariffs
  Future<TariffModel> create(TariffModel tariff) async {
    final response = await http
        .post(Uri.parse('$baseUrl/v1/tariffs'),
            headers: _headers(), body: json.encode(tariff.toCreateJson()))
        .timeout(const Duration(seconds: 15));
    return _parse(response, 'No se pudo crear la tarifa');
  }

  /// PATCH /v1/tariffs/{id}
  Future<TariffModel> update(TariffModel tariff) async {
    final response = await http
        .patch(Uri.parse('$baseUrl/v1/tariffs/${tariff.id}'),
            headers: _headers(), body: json.encode(tariff.toUpdateJson()))
        .timeout(const Duration(seconds: 15));
    return _parse(response, 'No se pudo actualizar la tarifa');
  }

  /// POST /v1/tariffs/{tariffId}/route-durations
  Future<RouteDurationModel> setRouteDuration({
    required int tariffId,
    required int fkIdRoute,
    required int estimatedMinutes,
  }) async {
    final response = await http
        .post(Uri.parse('$baseUrl/v1/tariffs/$tariffId/route-durations'),
            headers: _headers(),
            body: json.encode({'fkIdRoute': fkIdRoute, 'estimatedMinutes': estimatedMinutes}))
        .timeout(const Duration(seconds: 12));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return RouteDurationModel.fromJson(json.decode(response.body));
    }
    throw Exception('No se pudo guardar la duración: ${_message(response)}');
  }

  /// GET /v1/tariffs/{driverId}/route-durations/{routeId}
  Future<RouteDurationModel?> getRouteDuration(int driverId, int routeId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/v1/tariffs/$driverId/route-durations/$routeId'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return RouteDurationModel.fromJson(json.decode(response.body));
    }
    if (response.statusCode == 404) return null;
    throw Exception('Error al cargar la duración: ${response.statusCode}');
  }

  TariffModel _parse(http.Response response, String errorMsg) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return TariffModel.fromJson(json.decode(response.body));
    }
    throw Exception('$errorMsg: ${_message(response)}');
  }

  String _message(http.Response response) {
    try {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {/* non-JSON body */}
    return '${response.statusCode}';
  }
}
