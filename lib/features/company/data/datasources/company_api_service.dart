import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../models/company_model.dart';
import '../../domain/repositories/company_repository.dart';

class CompanyApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  String? _bearerToken;

  void setBearerToken(String token) {
    _bearerToken = token;
  }

  Map<String, String> _jsonHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_bearerToken != null && _bearerToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_bearerToken';
    }
    return headers;
  }

  Map<String, String> _authHeaders() {
    final headers = {'Accept': 'application/json'};
    if (_bearerToken != null && _bearerToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_bearerToken';
    }
    return headers;
  }

  Future<CompanyModel?> getCompanyForUser(String userId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/companies/user/$userId'), headers: _jsonHeaders())
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      if (response.body.trim().isEmpty || response.body.trim() == 'null') return null;
      return CompanyModel.fromJson(json.decode(response.body));
    }
    if (response.statusCode == 404) return null;
    throw Exception('Error al buscar empresa: ${response.statusCode}');
  }

  Future<CompanyModel> getCompany(int id) async {
    final response = await http
        .get(Uri.parse('$baseUrl/companies/$id'), headers: _jsonHeaders())
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return CompanyModel.fromJson(json.decode(response.body));
    }
    throw Exception('Error al cargar empresa: ${response.statusCode}');
  }

  Future<CompanyModel> createCompany({
    required String userId,
    required String name,
    required String ruc,
    required String phone,
    required String email,
    required String address,
    required String description,
    Uint8List? logoBytes,
    String? logoFileName,
  }) async {
    // Backend CreateCompanyFormResource only persists Name, FkIdUser, LogoFile.
    // Extra fields (ruc/phone/email/address/description) are saved via a
    // follow-up PUT once we know the company id.
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/companies'))
      ..headers.addAll(_authHeaders())
      ..fields.addAll({
        'Name': name,
        'FkIdUser': userId,
      });

    if (logoBytes != null && logoBytes.isNotEmpty) {
      request.files.add(http.MultipartFile.fromBytes(
        'LogoFile',
        logoBytes,
        filename: logoFileName ?? 'logo.jpg',
      ));
    }

    final streamed = await request.send().timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear empresa: ${response.statusCode} ${response.body}');
    }
    final created = CompanyModel.fromJson(json.decode(response.body));

    // Persistir el resto de campos sólo si el usuario los rellenó.
    final hasExtras = ruc.isNotEmpty || phone.isNotEmpty || email.isNotEmpty ||
        address.isNotEmpty || description.isNotEmpty;
    if (!hasExtras) return created;
    return updateCompany(created.copyWith(
      ruc: ruc,
      phone: phone,
      email: email,
      address: address,
      description: description,
    ));
  }

  Future<CompanyModel> updateCompany(CompanyModel company) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/companies/${company.id}'),
          headers: _jsonHeaders(),
          body: json.encode(company.toUpdateJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return CompanyModel.fromJson(json.decode(response.body));
    }
    if (response.statusCode == 204) return company;
    throw Exception('Error al actualizar empresa: ${response.statusCode}');
  }

  Future<CompanyStats> getStats(int companyId) async {
    // Trips por empresa no existe en el backend (solo /trips/user/{id} y /trips/driver/{id}).
    // Lo dejamos en 0 hasta que se exponga un agregado o se sume por driver.
    final stopsCount = await _countEndpoint('$baseUrl/stops/company/$companyId');
    final routesCount = await _countEndpoint('$baseUrl/routes/company/$companyId');
    return CompanyStats(stops: stopsCount, routes: routesCount);
  }

  Future<int> _countEndpoint(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: _jsonHeaders())
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200 || response.body.trim().isEmpty) return 0;
      final data = json.decode(response.body);
      if (data is List) return data.length;
      if (data is Map<String, dynamic>) {
        final count = data['count'] ?? data['total'] ?? data['items'];
        if (count is int) return count;
        if (count is List) return count.length;
      }
    } catch (_) {
      return 0;
    }
    return 0;
  }

  Future<String> getMapTileUrl() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/config/map'), headers: _jsonHeaders())
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final url = data['tileUrl'] ?? data['tileURL'] ?? data['url'];
        if (url is String && url.isNotEmpty) return url;
      }
    } catch (_) {
      // Fall back to public tiles.
    }
    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }
}
