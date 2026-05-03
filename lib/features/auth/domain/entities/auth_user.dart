class AuthUser {
  final String id;
  final String email;
  final String name;
  final String token;
  final String? refreshToken;
  final int role;

  AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
    this.refreshToken,
    this.role = 0,
  });
}
