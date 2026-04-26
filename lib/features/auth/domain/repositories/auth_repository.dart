import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> login(String email, String password);
  Future<AuthUser> register(String email, String password, String name);
  Future<void> logout();
  Future<AuthUser?> getCurrentUser();
  Future<void> saveUser(AuthUser user);
}