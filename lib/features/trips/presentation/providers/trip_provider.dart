import 'package:flutter/material.dart';
import '../../data/datasources/trip_api_service.dart';
import '../../data/models/trip_history_model.dart';

/// Drives the driver trip-management screen: the claimable pool (`available`),
/// the driver's own trips (`mine`), and the publish/take/start/complete/cancel actions.
/// The graph on the backend is the source of truth, so every mutation reloads the lists.
class TripProvider with ChangeNotifier {
  final TripApiService apiService;

  TripProvider({required this.apiService});

  List<TripHistoryModel> _available = [];
  List<TripHistoryModel> _mine = [];
  bool _loadingAvailable = false;
  bool _loadingMine = false;
  int? _actingTripId;
  String? _error;

  List<TripHistoryModel> get available => _available;
  List<TripHistoryModel> get mine => _mine;
  bool get loadingAvailable => _loadingAvailable;
  bool get loadingMine => _loadingMine;
  int? get actingTripId => _actingTripId;
  String? get error => _error;

  void setToken(String token) => apiService.setBearerToken(token);

  /// Loads both lists for the given driver. Failures land in [error] but never throw,
  /// so a down endpoint doesn't blank the whole screen.
  Future<void> loadForDriver(int driverId) async {
    _loadingAvailable = true;
    _loadingMine = true;
    _error = null;
    notifyListeners();

    await Future.wait([
      _loadAvailable(),
      _loadMine(driverId),
    ]);

    notifyListeners();
  }

  Future<void> _loadAvailable() async {
    try {
      _available = await apiService.getAvailable();
    } catch (e) {
      _error = _clean(e);
    } finally {
      _loadingAvailable = false;
    }
  }

  Future<void> _loadMine(int driverId) async {
    try {
      _mine = await apiService.getDriverHistory(driverId);
    } catch (e) {
      _error = _clean(e);
    } finally {
      _loadingMine = false;
    }
  }

  Future<bool> publish({
    required int fkIdUser,
    required int fkIdDriver,
    required int fkIdRoute,
    required int fkIdOriginStop,
    required int fkIdDestinationStop,
    required double? price,
    required int seats,
  }) async {
    return _guard(() async {
      await apiService.publish(
        fkIdUser: fkIdUser,
        fkIdDriver: fkIdDriver,
        fkIdRoute: fkIdRoute,
        fkIdOriginStop: fkIdOriginStop,
        fkIdDestinationStop: fkIdDestinationStop,
        price: price,
        seats: seats,
      );
      await loadForDriver(fkIdDriver);
    });
  }

  Future<bool> take(int tripId, int driverId) =>
      _actOn(tripId, driverId, () => apiService.assignDriver(tripId, driverId));

  Future<bool> start(int tripId, int driverId) =>
      _actOn(tripId, driverId, () => apiService.start(tripId));

  Future<bool> complete(int tripId, int driverId) =>
      _actOn(tripId, driverId, () => apiService.complete(tripId));

  Future<bool> cancel(int tripId, int driverId) =>
      _actOn(tripId, driverId, () => apiService.cancel(tripId));

  Future<bool> _actOn(int tripId, int driverId, Future<void> Function() action) async {
    _actingTripId = tripId;
    notifyListeners();
    final ok = await _guard(() async {
      await action();
      await loadForDriver(driverId);
    });
    _actingTripId = null;
    notifyListeners();
    return ok;
  }

  Future<bool> _guard(Future<void> Function() body) async {
    try {
      _error = null;
      await body();
      return true;
    } catch (e) {
      _error = _clean(e);
      notifyListeners();
      return false;
    }
  }

  String _clean(Object e) => e.toString().replaceAll('Exception: ', '');
}
