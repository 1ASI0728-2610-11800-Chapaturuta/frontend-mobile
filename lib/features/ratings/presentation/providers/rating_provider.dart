import 'package:flutter/material.dart';
import '../../domain/entities/rating.dart';
import '../../domain/repositories/rating_repository.dart';

class RatingProvider extends ChangeNotifier {
  final RatingRepository repository;

  RatingProvider({required this.repository});

  List<Rating> _ratings = [];
  bool _isLoading = false;
  String? _error;

  List<Rating> get ratings => _ratings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get averageScore {
    if (_ratings.isEmpty) return 0;
    return _ratings.map((r) => r.score).reduce((a, b) => a + b) / _ratings.length;
  }

  Future<void> loadRatings(int routeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _ratings = await repository.getRatingsForRoute(routeId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitRating({required int routeId, required double score, String? comment}) async {
    try {
      final rating = await repository.createRating(routeId: routeId, score: score, comment: comment);
      _ratings = [rating, ..._ratings];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
