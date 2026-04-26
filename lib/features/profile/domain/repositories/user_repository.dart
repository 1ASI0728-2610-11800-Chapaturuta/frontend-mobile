import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<void> updateUser(User user);
  Future<void> logout();
  Future<void> addFavoriteRoute(String routeId);
  Future<void> removeFavoriteRoute(String routeId);
}