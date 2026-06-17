import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../../../core/config/api_config.dart';
import '../models/company_stop_model.dart';
import '../models/district_option.dart';

class StopApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  String? _bearerToken;
  String? _tileUrl;

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

  Future<List<CompanyStopModel>> getStops(int driverId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/stops/driver/$driverId'), headers: _jsonHeaders())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) return data.map((j) => CompanyStopModel.fromJson(j)).toList();
      if (data is Map<String, dynamic> && data['items'] is List) {
        return (data['items'] as List).map((j) => CompanyStopModel.fromJson(j)).toList();
      }
      return [];
    }
    throw Exception('Error al cargar paraderos: ${response.statusCode}');
  }

  Future<CompanyStopModel> createStop(
    CompanyStopModel stop, {
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/stops'))
      ..headers.addAll(_authHeaders())
      ..fields.addAll(stop.toFields());
    if (imageBytes != null && imageBytes.isNotEmpty) {
      request.files.add(http.MultipartFile.fromBytes(
        'ImageFile',
        imageBytes,
        filename: imageFileName ?? 'stop.jpg',
      ));
    }
    final streamed = await request.send().timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CompanyStopModel.fromJson(json.decode(response.body));
    }
    throw Exception('Error al crear paradero: ${response.statusCode} ${response.body}');
  }

  Future<CompanyStopModel> updateStop(CompanyStopModel stop) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/stops/${stop.id}'),
          headers: _jsonHeaders(),
          body: json.encode(stop.toUpdateJson()),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return CompanyStopModel.fromJson(json.decode(response.body));
    }
    if (response.statusCode == 204) return stop;
    throw Exception('Error al actualizar paradero: ${response.statusCode} ${response.body}');
  }

  Future<void> deleteStop(int id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/stops/$id'), headers: _jsonHeaders())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200 || response.statusCode == 204) return;
    throw Exception('Error al eliminar paradero: ${response.statusCode}');
  }

  /// Devuelve la lista de distritos con sus IDs (para el selector del form).
  /// Hace fan-out a /geographic/{districts,provinces,regions} y une por FK.
  Future<List<DistrictOption>> getDistricts() async {
    try {
      final results = await Future.wait([
        _fetchList('$baseUrl/geographic/districts'),
        _fetchList('$baseUrl/geographic/provinces'),
        _fetchList('$baseUrl/geographic/regions'),
      ]);
      final districts = results[0];
      final provinces = {
        for (final p in results[1]) _intOf(p['id']): p,
      };
      final regions = {
        for (final r in results[2]) _intOf(r['id']): r,
      };
      return districts.map((d) {
        final fkProv = _intOf(d['fkIdProvince'] ?? d['provinceId']);
        final prov = provinces[fkProv];
        final fkReg = prov == null ? 0 : _intOf(prov['fkIdRegion'] ?? prov['regionId']);
        final reg = regions[fkReg];
        return DistrictOption(
          id: _intOf(d['id']),
          name: (d['name'] ?? '').toString(),
          province: (prov?['name'] ?? '').toString(),
          region: (reg?['name'] ?? '').toString(),
        );
      }).where((opt) => opt.id > 0 && opt.name.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchList(String url) async {
    final response = await http
        .get(Uri.parse(url), headers: _jsonHeaders())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return [];
    final data = json.decode(response.body);
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  int _intOf(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  Future<String> getMapTileUrl() async {
    if (_tileUrl != null) return _tileUrl!;
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/config/map'), headers: _jsonHeaders())
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final url = data['tileUrl'] ?? data['tileURL'] ?? data['url'];
        if (url is String && url.isNotEmpty) {
          _tileUrl = url;
          return url;
        }
      }
    } catch (_) {
      // fallback below
    }
    _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    return _tileUrl!;
  }
}
