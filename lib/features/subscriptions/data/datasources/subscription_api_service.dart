import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/plan_model.dart';
import '../models/subscription_model.dart';

/// REST client for Plans (`/api/v1/plans`) and Subscriptions (`/api/v1/subscriptions`),
/// verified against PlansController and SubscriptionsController.
class SubscriptionApiService {
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

  // ── Plans ────────────────────────────────────────────────────────────────

  /// GET /v1/plans
  Future<List<PlanModel>> getPlans() async {
    final response = await http
        .get(Uri.parse('$baseUrl/v1/plans'), headers: _headers())
        .timeout(const Duration(seconds: 12));
    return _parsePlans(response);
  }

  /// GET /v1/plans/by-target-role/{role}  (Traveller | Driver | Both)
  Future<List<PlanModel>> getPlansByTargetRole(String role) async {
    final response = await http
        .get(Uri.parse('$baseUrl/v1/plans/by-target-role/$role'), headers: _headers())
        .timeout(const Duration(seconds: 12));
    return _parsePlans(response);
  }

  // ── Subscriptions ──────────────────────────────────────────────────────────

  /// POST /v1/subscriptions. Free plans activate at once; Premium returns a
  /// PendingPayment subscription carrying `fkIdPayment` to confirm.
  Future<SubscriptionModel> subscribe({
    required int fkIdUser,
    required int fkIdPlan,
    bool autoRenew = true,
    String paymentMethod = 'Yape',
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/v1/subscriptions'),
          headers: _headers(),
          body: json.encode({
            'fkIdUser': fkIdUser,
            'fkIdPlan': fkIdPlan,
            'autoRenew': autoRenew,
            'paymentMethod': paymentMethod,
          }),
        )
        .timeout(const Duration(seconds: 15));
    return _parseSubscription(response, 'No se pudo suscribir al plan');
  }

  /// POST /v1/subscriptions/{id}/cancel
  Future<SubscriptionModel> cancel(int subscriptionId) async {
    final response = await http
        .post(Uri.parse('$baseUrl/v1/subscriptions/$subscriptionId/cancel'), headers: _headers())
        .timeout(const Duration(seconds: 12));
    return _parseSubscription(response, 'No se pudo cancelar la suscripción');
  }

  /// POST /v1/subscriptions/{id}/renew
  Future<SubscriptionModel> renew(int subscriptionId, {String paymentMethod = 'Yape'}) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/v1/subscriptions/$subscriptionId/renew'),
          headers: _headers(),
          body: json.encode({'paymentMethod': paymentMethod}),
        )
        .timeout(const Duration(seconds: 15));
    return _parseSubscription(response, 'No se pudo renovar la suscripción');
  }

  /// GET /v1/subscriptions/active/by-user/{userId} — null when none (404).
  Future<SubscriptionModel?> getActiveByUser(int userId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/v1/subscriptions/active/by-user/$userId'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return SubscriptionModel.fromJson(json.decode(response.body));
    }
    if (response.statusCode == 404) return null;
    throw Exception('Error al cargar la suscripción: ${response.statusCode}');
  }

  /// GET /v1/subscriptions/active/premium-status/by-user/{userId} → { isPremium }
  Future<bool> getPremiumStatus(int userId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/v1/subscriptions/active/premium-status/by-user/$userId'),
            headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic>) return data['isPremium'] == true;
    }
    return false;
  }

  /// GET /v1/subscriptions/history/by-user/{userId}
  Future<List<SubscriptionModel>> getHistory(int userId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/v1/subscriptions/history/by-user/$userId'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((j) => SubscriptionModel.fromJson(j as Map<String, dynamic>)).toList();
      }
      return [];
    }
    if (response.statusCode == 404) return [];
    throw Exception('Error al cargar el historial: ${response.statusCode}');
  }

  List<PlanModel> _parsePlans(http.Response response) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((j) => PlanModel.fromJson(j as Map<String, dynamic>)).toList();
      }
      return [];
    }
    if (response.statusCode == 404) return [];
    throw Exception('Error al cargar planes: ${response.statusCode}');
  }

  SubscriptionModel _parseSubscription(http.Response response, String errorMsg) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return SubscriptionModel.fromJson(json.decode(response.body));
    }
    throw Exception('$errorMsg: ${_message(response)}');
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
