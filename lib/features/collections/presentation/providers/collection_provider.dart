import 'package:flutter/material.dart';
import '../../data/datasources/collection_api_service.dart';
import '../../data/models/collection_model.dart';

/// Holds the user's collections and drives create/rename/delete and route add/remove.
class CollectionProvider with ChangeNotifier {
  final CollectionApiService apiService;

  CollectionProvider({required this.apiService});

  List<CollectionModel> _collections = [];
  bool _isLoading = false;
  String? _error;

  List<CollectionModel> get collections => _collections;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setToken(String token) => apiService.setBearerToken(token);

  Future<void> load(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _collections = await apiService.getByUser(userId);
    } catch (e) {
      _error = _clean(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(String name, int userId) async {
    try {
      final created = await apiService.create(name, userId);
      _collections = [..._collections, created];
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _clean(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> rename(int id, String name) async {
    try {
      final updated = await apiService.rename(id, name);
      final idx = _collections.indexWhere((c) => c.id == id);
      if (idx >= 0) _collections[idx] = updated;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _clean(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await apiService.delete(id);
      _collections.removeWhere((c) => c.id == id);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _clean(e);
      notifyListeners();
      return false;
    }
  }

  /// Adds a route to a collection. Returns an error message on failure, null on success.
  Future<String?> addRoute(int collectionId, int routeId) async {
    try {
      await apiService.addRoute(collectionId, routeId);
      final idx = _collections.indexWhere((c) => c.id == collectionId);
      if (idx >= 0) {
        _collections[idx] = _collections[idx].copyWith(itemCount: _collections[idx].itemCount + 1);
        notifyListeners();
      }
      return null;
    } catch (e) {
      return _clean(e);
    }
  }

  Future<bool> removeRoute(int collectionId, int routeId) async {
    try {
      await apiService.removeRoute(collectionId, routeId);
      final idx = _collections.indexWhere((c) => c.id == collectionId);
      if (idx >= 0 && _collections[idx].itemCount > 0) {
        _collections[idx] = _collections[idx].copyWith(itemCount: _collections[idx].itemCount - 1);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = _clean(e);
      notifyListeners();
      return false;
    }
  }

  String _clean(Object e) => e.toString().replaceAll('Exception: ', '');
}
