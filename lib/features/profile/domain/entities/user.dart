class User {
  final String id;
  final String name;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String gender;
  final List<String> favoriteRoutes;
  final int? driverId;

  User({
    required this.id,
    required this.name,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.gender,
    this.favoriteRoutes = const [],
    this.driverId,
  });

  String get fullName => '$name $lastName';
}
