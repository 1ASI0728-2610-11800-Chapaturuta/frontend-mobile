import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/payment_model.dart';

/// REST client for Payments (`/api/v1/payments`), verified against PaymentsController.
///
/// The reservation flow already creates a Pending payment (the reservation carries its
/// `fkIdPayment`), so the app only needs to *confirm* it. Confirming a payment also
/// activates the reservation it backs (backend PaymentConfirmationService).
class PaymentApiService {
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

  /// Confirms a payment with a (simulated) gateway reference. POST /v1/payments/{id}/confirm
  Future<PaymentModel> confirm(int paymentId, String externalReference) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/v1/payments/$paymentId/confirm'),
          headers: _headers(),
          body: json.encode({'externalReference': externalReference}),
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      return PaymentModel.fromJson(json.decode(response.body));
    }
    throw Exception('No se pudo confirmar el pago: ${_message(response)}');
  }

  /// GET /v1/payments/{id}
  Future<PaymentModel?> getById(int paymentId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/v1/payments/$paymentId'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return PaymentModel.fromJson(json.decode(response.body));
    }
    if (response.statusCode == 404) return null;
    throw Exception('Error al cargar el pago: ${response.statusCode}');
  }

  /// Payments made by a user. GET /v1/payments/user/{userId}
  Future<List<PaymentModel>> getByUser(int userId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/v1/payments/user/$userId'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((j) => PaymentModel.fromJson(j as Map<String, dynamic>)).toList();
      }
      return [];
    }
    if (response.statusCode == 404) return [];
    throw Exception('Error al cargar pagos: ${response.statusCode}');
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
