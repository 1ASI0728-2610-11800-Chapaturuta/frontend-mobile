import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/driver_model.dart';

class DriverApiService {
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

  Future<DriverModel?> getDriverByUser(String userId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/v1/drivers/by-user/$userId'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return DriverModel.fromJson(json.decode(response.body));
    }
    if (response.statusCode == 404) return null;
    throw Exception('Error al buscar conductor: ${response.statusCode}');
  }

  Future<DriverModel> createDriver({
    required String fkIdUser,
    required String firstName,
    required String lastName,
    required String documentNumber,
    required String phone,
    required String licenseNumber,
    required String licenseCategory,
    required String vehiclePlate,
    required String vehicleBrand,
    required String vehicleModel,
    required int vehicleYear,
    required int vehicleCapacity,
    required String vehicleType,
  }) async {
    final body = {
      'fkIdUser': int.tryParse(fkIdUser) ?? 0,
      'firstName': firstName,
      'lastName': lastName,
      'documentNumber': documentNumber,
      'phone': phone,
      'photoUrl': '',
      'licenseNumber': licenseNumber,
      'licenseCategory': licenseCategory,
      'vehiclePlate': vehiclePlate,
      'vehicleBrand': vehicleBrand,
      'vehicleModel': vehicleModel,
      'vehicleYear': vehicleYear,
      'vehicleCapacity': vehicleCapacity,
      'vehicleType': vehicleType,
    };
    final response = await http
        .post(Uri.parse('$baseUrl/v1/drivers'), headers: _headers(), body: json.encode(body))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return DriverModel.fromJson(json.decode(response.body));
    }
    throw Exception('Error al crear conductor: ${response.statusCode} ${response.body}');
  }

  /// Flips the driver's availability. PATCH /v1/drivers/{id}/availability
  Future<DriverModel> toggleAvailability(int driverId) async {
    final response = await http
        .patch(Uri.parse('$baseUrl/v1/drivers/$driverId/availability'), headers: _headers())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return DriverModel.fromJson(json.decode(response.body));
    }
    throw Exception('No se pudo cambiar la disponibilidad: ${response.statusCode}');
  }
}
