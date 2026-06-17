import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/models/user_model.dart';

class UserProvider with ChangeNotifier {
  final UserRepository repository;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserProvider({required this.repository});

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
    );
    await updateUser(updated);
  }

  Future<void> logout() async {
    try {
      await repository.logout();
      _currentUser = null;
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
