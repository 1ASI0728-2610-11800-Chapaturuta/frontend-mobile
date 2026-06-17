import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../data/datasources/stop_api_service.dart';
import '../../data/models/company_stop_model.dart';
import '../../data/models/district_option.dart';

class StopProvider with ChangeNotifier {
  final StopApiService apiService;

  List<CompanyStopModel> _stops = [];
  List<DistrictOption> _districts = [];
  String _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  bool _isLoading = false;
  String? _error;

  StopProvider({required this.apiService});

  List<CompanyStopModel> get stops => _stops;
  List<DistrictOption> get districts => _districts;
  String get tileUrl => _tileUrl;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setToken(String token) => apiService.setBearerToken(token);

  Future<void> load(int driverId) async {
    _setLoading(true);
    try {
      _tileUrl = await apiService.getMapTileUrl();
      _stops = await apiService.getStops(driverId);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }
    _setLoading(false);
  }

  Future<void> loadDistricts() async {
    if (_districts.isNotEmpty) return;
    _districts = await apiService.getDistricts();
    notifyListeners();
  }

  Future<bool> save(
    CompanyStopModel stop, {
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    _setLoading(true);
    try {
      final saved = stop.id == 0
          ? await apiService.createStop(stop, imageBytes: imageBytes, imageFileName: imageFileName)
          : await apiService.updateStop(stop);
      final index = _stops.indexWhere((item) => item.id == saved.id);
      if (index >= 0) {
        _stops[index] = saved;
      } else {
        _stops.add(saved);
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
      await apiService.deleteStop(id);
      _stops.removeWhere((item) => item.id == id);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
