import 'package:flutter/material.dart';
import '../../../routes/data/models/route_model.dart';
import '../../data/datasources/discovery_api_service.dart';
import '../../data/models/search_result_model.dart';

/// Backs the "Descubrir" screen: popular routes on entry and origin/destination search.
/// Discovery calls are metered by the backend, so a Free-plan user can hit a quota (403),
/// surfaced via [quotaMessage].
class DiscoveryProvider with ChangeNotifier {
  final DiscoveryApiService apiService;

  DiscoveryProvider({required this.apiService});

  List<TransportRouteModel> _popular = [];
  List<SearchResultModel> _results = [];
  bool _loadingPopular = false;
  bool _loadingSearch = false;
  bool _hasSearched = false;
  String? _error;
  String? _quotaMessage;

  List<TransportRouteModel> get popular => _popular;
  List<SearchResultModel> get results => _results;
  bool get loadingPopular => _loadingPopular;
  bool get loadingSearch => _loadingSearch;
  bool get hasSearched => _hasSearched;
  String? get error => _error;
  String? get quotaMessage => _quotaMessage;

  void setToken(String token) => apiService.setBearerToken(token);

  Future<void> loadPopular(int userId, {int limit = 10}) async {
    _loadingPopular = true;
    _error = null;
    _quotaMessage = null;
    notifyListeners();
    try {
      _popular = await apiService.popular(userId: userId, limit: limit);
    } on DiscoveryQuotaException catch (e) {
      _quotaMessage = e.message;
    } catch (e) {
      _error = _clean(e);
    } finally {
      _loadingPopular = false;
      notifyListeners();
    }
  }

  Future<void> search(int userId, {String? origin, String? destination}) async {
    _loadingSearch = true;
    _hasSearched = true;
    _error = null;
    _quotaMessage = null;
    notifyListeners();
    try {
      _results = await apiService.search(
        userId: userId,
        origin: origin,
        destination: destination,
      );
    } on DiscoveryQuotaException catch (e) {
      _quotaMessage = e.message;
      _results = [];
    } catch (e) {
      _error = _clean(e);
      _results = [];
    } finally {
      _loadingSearch = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _results = [];
    _hasSearched = false;
    _error = null;
    _quotaMessage = null;
    notifyListeners();
  }

  String _clean(Object e) => e.toString().replaceAll('Exception: ', '');
}
