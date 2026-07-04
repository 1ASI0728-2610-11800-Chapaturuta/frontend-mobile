import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/trip_history_model.dart';
import '../models/trip_summary_model.dart';

/// REST client for the Trips bounded context (`/api/trips`).
/// Endpoints verified against the backend TripsController.
class TripApiService {
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

  // ── Driver-facing reads ────────────────────────────────────────────────────

  /// Enriched history for a driver's trips (resolved names). GET /trips/driver/{id}/history
  Future<List<TripHistoryModel>> getDriverHistory(int driverId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/trips/driver/$driverId/history'), headers: _headers())
        .timeout(const Duration(seconds: 12));
    return _parseHistoryList(response, 'No se pudieron cargar tus viajes');
  }

  /// Pending trips with no driver assigned — the claimable pool. GET /trips/available
  Future<List<TripHistoryModel>> getAvailable() async {
    final response = await http
        .get(Uri.parse('$baseUrl/trips/available'), headers: _headers())
        .timeout(const Duration(seconds: 12));
    return _parseHistoryList(response, 'No se pudieron cargar los viajes disponibles');
  }

  /// Published trips a passenger can still board. GET /trips/joinable?routeId=
  Future<List<TripHistoryModel>> getJoinable({int? routeId}) async {
    final uri = routeId != null
        ? Uri.parse('$baseUrl/trips/joinable?routeId=$routeId')
        : Uri.parse('$baseUrl/trips/joinable');
    final response = await http.get(uri, headers: _headers()).timeout(const Duration(seconds: 12));
    return _parseHistoryList(response, 'No se pudieron cargar los viajes');
  }

  /// Enriched history for a passenger's trips. GET /trips/user/{id}/history
  Future<List<TripHistoryModel>> getUserHistory(int userId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/trips/user/$userId/history'), headers: _headers())
        .timeout(const Duration(seconds: 12));
    return _parseHistoryList(response, 'No se pudo cargar el historial');
  }

  // ── Driver-facing writes ───────────────────────────────────────────────────

  /// Driver publishes a shared trip with seat capacity. POST /trips/publish
  Future<TripSummaryModel> publish({
    required int fkIdUser,
    required int fkIdDriver,
    required int fkIdRoute,
    required int fkIdOriginStop,
    required int fkIdDestinationStop,
    required double? price,
    required int seats,
  }) async {
    final body = <String, dynamic>{
      'fkIdUser': fkIdUser,
      'fkIdDriver': fkIdDriver,
      'fkIdRoute': fkIdRoute,
      'fkIdOriginStop': fkIdOriginStop,
      'fkIdDestinationStop': fkIdDestinationStop,
      'price': price,
      'seats': seats,
    };
    final response = await http
        .post(Uri.parse('$baseUrl/trips/publish'), headers: _headers(), body: json.encode(body))
        .timeout(const Duration(seconds: 15));
    return _parseTrip(response, 'No se pudo publicar el viaje');
  }

  /// Driver claims a pending trip. POST /trips/{id}/assign-driver
  Future<TripSummaryModel> assignDriver(int tripId, int driverId) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/trips/$tripId/assign-driver'),
          headers: _headers(),
          body: json.encode({'driverId': driverId}),
        )
        .timeout(const Duration(seconds: 12));
    return _parseTrip(response, 'No se pudo tomar el viaje');
  }

  Future<TripSummaryModel> start(int tripId) => _action(tripId, 'start', 'No se pudo iniciar el viaje');
  Future<TripSummaryModel> complete(int tripId) =>
      _action(tripId, 'complete', 'No se pudo completar el viaje');
  Future<TripSummaryModel> cancel(int tripId) =>
      _action(tripId, 'cancel', 'No se pudo cancelar el viaje');

  Future<TripSummaryModel> _action(int tripId, String verb, String errorMsg) async {
    final response = await http
        .post(Uri.parse('$baseUrl/trips/$tripId/$verb'), headers: _headers())
        .timeout(const Duration(seconds: 12));
    return _parseTrip(response, errorMsg);
  }

  // ── Parsing helpers ────────────────────────────────────────────────────────

  List<TripHistoryModel> _parseHistoryList(http.Response response, String errorMsg) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data
            .map((j) => TripHistoryModel.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      return [];
    }
    if (response.statusCode == 404) return [];
    throw Exception('$errorMsg (${response.statusCode})');
  }

  TripSummaryModel _parseTrip(http.Response response, String errorMsg) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return TripSummaryModel.fromJson(json.decode(response.body));
    }
    throw Exception('$errorMsg: ${_extractMessage(response)}');
  }

  /// Pulls the backend's `{ "message": "..." }` payload when present, so the UI
  /// can surface the real rule violation instead of a bare status code.
  String _extractMessage(http.Response response) {
    try {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {/* non-JSON body */}
    return '${response.statusCode}';
  }
}
