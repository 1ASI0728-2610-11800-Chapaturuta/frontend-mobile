import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';

import '../../data/datasources/company_route_api_service.dart';
import '../../data/models/company_route_model.dart';

class CompanyRouteProvider with ChangeNotifier {
  final CompanyRouteApiService apiService;

  List<CompanyRouteModel> _routes = [];
  String _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  bool _isLoading = false;
  String? _error;

  CompanyRouteProvider({required this.apiService});

  List<CompanyRouteModel> get routes => _routes;
  String get tileUrl => _tileUrl;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setToken(String token) => apiService.setBearerToken(token);

  Future<void> load(int driverId) async {
    _setLoading(true);
    try {
      _tileUrl = await apiService.getMapTileUrl();
      _routes = await apiService.getRoutes(driverId);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }
    _setLoading(false);
  }

  Future<bool> save(CompanyRouteModel route) async {
    _setLoading(true);
    try {
      final saved = route.id == 0 ? await apiService.createRoute(route) : await apiService.updateRoute(route);
      final index = _routes.indexWhere((item) => item.id == saved.id);
      if (index >= 0) {
        _routes[index] = saved;
      } else {
        _routes.add(saved);
      }
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> remove(int id) async {
    _setLoading(true);
    try {
      await apiService.deleteRoute(id);
      _routes.removeWhere((item) => item.id == id);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Acepta polyline encoded (string), GeoJSON LineString, o array crudo.
  Future<List<LatLng>> loadGeometry(CompanyRouteModel route) async {
    dynamic raw = route.geometry ?? await apiService.getGeometry(route.id);
    if (raw == null) return [];

    if (raw is String && raw.isNotEmpty) {
      final points = PolylinePoints().decodePolyline(raw);
      return points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    }
    if (raw is Map<String, dynamic> && raw['coordinates'] is List) {
      // GeoJSON LineString: [lng, lat]
      return (raw['coordinates'] as List)
          .whereType<List>()
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
    }
    if (raw is List) {
      // Array genérico: [[lat,lng], ...] o [{lat,lng}, ...]
      return raw.map((p) {
        if (p is List && p.length >= 2) {
          return LatLng((p[0] as num).toDouble(), (p[1] as num).toDouble());
        }
        if (p is Map<String, dynamic>) {
          final lat = (p['lat'] ?? p['latitude']) as num? ?? 0;
          final lng = (p['lng'] ?? p['longitude']) as num? ?? 0;
          return LatLng(lat.toDouble(), lng.toDouble());
        }
        return const LatLng(0, 0);
      }).where((p) => p.latitude != 0 || p.longitude != 0).toList();
    }
    return [];
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
