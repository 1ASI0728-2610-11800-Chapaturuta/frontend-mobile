import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  static const String _userKey = 'current_user';
  
  // 1. ELIMINAMOS EL USUARIO DE EJEMPLO (_defaultUser)
  // Ya no hardcodeamos a "Sabrina"

  @override
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final userData = json.decode(userJson);
        return UserModel.fromJson(userData);
      }
      
      // 2. CORREGIDO: Si no hay usuario guardado, devolvemos null.
      // Esto le dice a la app "Nadie ha iniciado sesión".
      return null; 

    } catch (e) {
      // En caso de error, también devolvemos null
      return null;
    }
  }

  @override
  Future<void> updateUser(User user) async {
    await _saveUser(user);
  }

  // Este método es privado pero útil para guardar cuando haces Login real
  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Convertimos la entidad User a UserModel si es necesario
    final userModel = user is UserModel ? user : UserModel(
      id: user.id,
      name: user.name,
      lastName: user.lastName,
      username: user.username,
      email: user.email,
      phone: user.phone,
      gender: user.gender,
      favoriteRoutes: user.favoriteRoutes,
      companyId: user.companyId,
    );
    
    await prefs.setString(_userKey, json.encode(userModel.toJson()));
  }

  // Método público para guardar usuario (Útil para llamar desde el AuthProvider al hacer login)
  Future<void> saveUserSession(UserModel user) async {
    await _saveUser(user);
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  @override
  Future<void> addFavoriteRoute(String routeId) async {
    final user = await getCurrentUser();
    // Solo agrega si hay un usuario real logueado
    if (user != null && !user.favoriteRoutes.contains(routeId)) {
      final updatedUser = UserModel(
        id: user.id,
        name: user.name,
        lastName: user.lastName,
        username: user.username,
        email: user.email,
        phone: user.phone,
        gender: user.gender,
        favoriteRoutes: [...user.favoriteRoutes, routeId],
        companyId: user.companyId,
      );
      await _saveUser(updatedUser);
    }
  }

  @override
  Future<void> removeFavoriteRoute(String routeId) async {
    final user = await getCurrentUser();
    // Solo elimina si hay un usuario real logueado
    if (user != null) {
      final updatedRoutes = user.favoriteRoutes.where((id) => id != routeId).toList();
      final updatedUser = UserModel(
        id: user.id,
        name: user.name,
        lastName: user.lastName,
        username: user.username,
        email: user.email,
        phone: user.phone,
        gender: user.gender,
        favoriteRoutes: updatedRoutes,
        companyId: user.companyId,
      );
      await _saveUser(updatedUser);
    }
  }
}
