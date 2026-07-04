import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/journey_models.dart';

/// Thrown when the assistant rejects the request because the user isn't Premium (HTTP 403).
class AssistantPremiumRequiredException implements Exception {
  final String message;
  AssistantPremiumRequiredException(this.message);
  @override
  String toString() => message;
}

/// Client for the Premium travel assistant (`POST /api/discovery/assistant`).
/// The call runs an LLM + per-leg OSRM, so it can take tens of seconds — wide timeout.
class AssistantApiService {
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

  Future<AssistantReply> ask({required int userId, required String message}) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/discovery/assistant'),
          headers: _headers(),
          body: json.encode({'userId': userId, 'message': message}),
        )
        .timeout(const Duration(seconds: 90));

    if (response.statusCode == 200) {
      return AssistantReply.fromJson(json.decode(response.body));
    }
    if (response.statusCode == 403) {
      throw AssistantPremiumRequiredException(_message(
          response, 'El Asistente IA es exclusivo del plan Premium.'));
    }
    throw Exception('El asistente no pudo responder (${response.statusCode})');
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
