import 'package:flutter/material.dart';
import '../../data/datasources/tariff_api_service.dart';
import '../../data/models/tariff_model.dart';

/// Holds the driver's active tariff and persists create/update. A null [tariff]
/// after a successful [load] means the driver hasn't configured one yet.
class TariffProvider with ChangeNotifier {
  final TariffApiService apiService;

  TariffProvider({required this.apiService});

  TariffModel? _tariff;
  bool _isLoading = false;
  bool _loaded = false;
  String? _error;

  TariffModel? get tariff => _tariff;
  bool get isLoading => _isLoading;
  bool get loaded => _loaded;
  bool get hasTariff => _tariff != null;
  String? get error => _error;

  void setToken(String token) => apiService.setBearerToken(token);

  Future<void> load(int driverId) async {
    _setLoading(true);
    try {
      _tariff = await apiService.getByDriver(driverId);
      _error = null;
    } catch (e) {
      _error = _clean(e);
    }
    _loaded = true;
    _setLoading(false);
  }

  /// Creates the tariff if new (id == 0), otherwise updates it. Returns success.
  Future<bool> save(TariffModel tariff) async {
    _setLoading(true);
    try {
      _tariff = tariff.id == 0 ? await apiService.create(tariff) : await apiService.update(tariff);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = _clean(e);
      _setLoading(false);
      return false;
    }
  }

  Future<RouteDurationModel?> setRouteDuration({
    required int fkIdRoute,
    required int estimatedMinutes,
  }) async {
    final tariff = _tariff;
    if (tariff == null) {
      _error = 'Primero crea tu tarifa.';
      notifyListeners();
      return null;
    }
    try {
      final result = await apiService.setRouteDuration(
        tariffId: tariff.id,
        fkIdRoute: fkIdRoute,
        estimatedMinutes: estimatedMinutes,
      );
      _error = null;
      notifyListeners();
      return result;
    } catch (e) {
      _error = _clean(e);
      notifyListeners();
      return null;
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  String _clean(Object e) => e.toString().replaceAll('Exception: ', '');
}
