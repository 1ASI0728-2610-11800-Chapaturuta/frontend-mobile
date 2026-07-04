import 'package:flutter/material.dart';
import '../../data/datasources/rating_api_service.dart';
import '../../data/models/rating_model.dart';

/// Handles submitting a rating for a driver after a completed trip, plus reading a
/// driver's ratings and summary.
class RatingProvider with ChangeNotifier {
  final RatingApiService apiService;

  RatingProvider({required this.apiService});

  List<RatingModel> _driverRatings = [];
  RatingSummary? _summary;
  bool _isSubmitting = false;
  bool _isLoading = false;
  String? _error;

  List<RatingModel> get driverRatings => _driverRatings;
  RatingSummary? get summary => _summary;
  bool get isSubmitting => _isSubmitting;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setToken(String token) => apiService.setToken(token);

  Future<bool> submit({
    required int fkIdUser,
    required int fkIdDriver,
    required int fkIdTrip,
    required int score,
    String? comment,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      await apiService.create(
        fkIdUser: fkIdUser,
        fkIdDriver: fkIdDriver,
        fkIdTrip: fkIdTrip,
        score: score,
        comment: comment,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadForDriver(int driverId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        apiService.getByDriver(driverId),
        apiService.getDriverSummary(driverId),
      ]);
      _driverRatings = results[0] as List<RatingModel>;
      _summary = results[1] as RatingSummary?;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
