import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/models/user_model.dart';

class ProfileStats {
  final int trips;
  final int collections;
  final int ratings;

  const ProfileStats({this.trips = 0, this.collections = 0, this.ratings = 0});
}

class UserProvider with ChangeNotifier {
  final UserRepository repository;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  ProfileStats _stats = const ProfileStats();

  UserProvider({required this.repository});

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ProfileStats get stats => _stats;

  String? _token;
  void setToken(String token) {
    _token = token;
  }

  Future<void> loadCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await repository.getCurrentUser();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar usuario';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfileStats() async {
    final user = _currentUser;
    if (user == null) return;

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    int trips = 0;
    int collections = 0;
    int ratings = 0;

    try {
      final userId = int.tryParse(user.id) ?? 0;
      final baseUrl = ApiConfig.baseUrl;

      final results = await Future.wait([
        http.get(Uri.parse('$baseUrl/trips/user/$userId/history'), headers: headers).catchError((_) => http.Response('[]', 200)),
        http.get(Uri.parse('$baseUrl/collections/user/$userId'), headers: headers).catchError((_) => http.Response('[]', 200)),
        http.get(Uri.parse('$baseUrl/ratings/user/$userId'), headers: headers).catchError((_) => http.Response('[]', 200)),
      ]);

      if (results[0].statusCode == 200) {
        final data = json.decode(results[0].body);
        if (data is List) trips = data.length;
      }
      if (results[1].statusCode == 200) {
        final data = json.decode(results[1].body);
        if (data is List) collections = data.length;
      }
      if (results[2].statusCode == 200) {
        final data = json.decode(results[2].body);
        if (data is List) ratings = data.length;
      }
    } catch (_) {}

    _stats = ProfileStats(trips: trips, collections: collections, ratings: ratings);
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await repository.updateUser(user);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al actualizar usuario';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDriverId(int driverId) async {
    final user = _currentUser;
    if (user == null || user.driverId == driverId) return;

    final updated = UserModel(
      id: user.id,
      name: user.name,
      lastName: user.lastName,
      username: user.username,
      email: user.email,
      phone: user.phone,
      gender: user.gender,
      favoriteRoutes: user.favoriteRoutes,
      driverId: driverId,
      role: user.role,
    );
    await updateUser(updated);
  }

  Future<void> logout() async {
    try {
      await repository.logout();
      _currentUser = null;
      _stats = const ProfileStats();
      _token = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cerrar sesión';
      notifyListeners();
    }
  }

  Future<void> addFavoriteRoute(String routeId) async {
    try {
      await repository.addFavoriteRoute(routeId);
      await loadCurrentUser();
    } catch (e) {
      _error = 'Error al agregar favorito';
      notifyListeners();
    }
  }

  Future<void> removeFavoriteRoute(String routeId) async {
    try {
      await repository.removeFavoriteRoute(routeId);
      await loadCurrentUser();
    } catch (e) {
      _error = 'Error al eliminar favorito';
      notifyListeners();
    }
  }
}
