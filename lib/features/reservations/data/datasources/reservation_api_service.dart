import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/reservation_model.dart';

class ReservationApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  String? _bearerToken;

  void setBearerToken(String token) {
    _bearerToken = token;
  }

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

  /// Creates a trip + reservation in sequence.
  /// 1. POST /api/trips -> get tripId
  /// 2. POST /api/v1/reservations -> get reservation
  Future<ReservationModel> createReservation({
    required int userId,
    required int routeId,
    required int originStopId,
    required int destinationStopId,
    required int driverId,
    required double price,
    required int seats,
    required String documentNumber,
    required String paymentMethod,
    required int availableSeats,
  }) async {
    final tripBody = <String, dynamic>{
      'fkIdUser': userId,
      'fkIdRoute': routeId,
      'fkIdOriginStop': originStopId,
      'fkIdDestinationStop': destinationStopId,
      'price': price,
      'availableSeats': availableSeats,
    };
    if (driverId > 0) {
      tripBody['fkIdDriver'] = driverId;
    }

    final tripResponse = await http.post(
      Uri.parse('$baseUrl/trips'),
      headers: _headers(),
      body: json.encode(tripBody),
    ).timeout(const Duration(seconds: 15));

    if (tripResponse.statusCode != 200 && tripResponse.statusCode != 201) {
      final body = tripResponse.body;
      throw Exception('Error al crear viaje: ${tripResponse.statusCode} $body');
    }

    final tripData = json.decode(tripResponse.body);
    final tripId = tripData['id'] as int;

    // Step 2: Create reservation
    final resResponse = await http.post(
      Uri.parse('$baseUrl/v1/reservations'),
      headers: _headers(),
      body: json.encode({
        'fkIdUser': userId,
        'fkIdTrip': tripId,
        'documentType': 'Dni',
        'documentNumber': documentNumber,
        'seats': seats,
        'paymentMethod': paymentMethod,
      }),
    ).timeout(const Duration(seconds: 15));

    if (resResponse.statusCode == 200 || resResponse.statusCode == 201) {
      return ReservationModel.fromJson(json.decode(resResponse.body));
    }
    throw Exception('Error al crear reserva: ${resResponse.statusCode} ${resResponse.body}');
  }

  Future<List<ReservationModel>> getByUser(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/reservations/by-user/$userId'),
      headers: _headers(),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((j) => ReservationModel.fromJson(j as Map<String, dynamic>)).toList();
      }
      return [];
    }
    if (response.statusCode == 404) return [];
    throw Exception('Error al cargar reservas: ${response.statusCode}');
  }

  Future<ReservationModel> confirm(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/reservations/$id/confirm'),
      headers: _headers(),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return ReservationModel.fromJson(json.decode(response.body));
    }
    throw Exception('Error al confirmar reserva: ${response.statusCode}');
  }

  Future<ReservationModel> cancel(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/reservations/$id/cancel'),
      headers: _headers(),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return ReservationModel.fromJson(json.decode(response.body));
    }
    throw Exception('Error al cancelar reserva: ${response.statusCode}');
  }
}
