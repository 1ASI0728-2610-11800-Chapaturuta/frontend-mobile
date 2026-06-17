import 'package:flutter/material.dart';
import '../../data/datasources/reservation_api_service.dart';
import '../../data/models/reservation_model.dart';

class ReservationProvider with ChangeNotifier {
  final ReservationApiService apiService;

  List<ReservationModel> _reservations = [];
  bool _isLoading = false;
  String? _error;

  ReservationProvider({required this.apiService});

  List<ReservationModel> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setToken(String token) => apiService.setBearerToken(token);

  Future<void> loadByUser(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reservations = await apiService.getByUser(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReservationModel?> createReservation({
    required int userId,
    required int routeId,
    required int originStopId,
    required int destinationStopId,
    required int driverId,
    required double price,
    required int seats,
    required String documentNumber,
    required String paymentMethod,
    required int availableSeats,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final reservation = await apiService.createReservation(
        userId: userId,
        routeId: routeId,
        originStopId: originStopId,
        destinationStopId: destinationStopId,
        driverId: driverId,
        price: price,
        seats: seats,
        documentNumber: documentNumber,
        paymentMethod: paymentMethod,
        availableSeats: availableSeats,
      );
      _reservations.insert(0, reservation);
      _isLoading = false;
      notifyListeners();
      return reservation;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> confirm(int id) async {
    try {
      final updated = await apiService.confirm(id);
      final idx = _reservations.indexWhere((r) => r.id == id);
      if (idx >= 0) _reservations[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancel(int id) async {
    try {
      final updated = await apiService.cancel(id);
      final idx = _reservations.indexWhere((r) => r.id == id);
      if (idx >= 0) _reservations[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
