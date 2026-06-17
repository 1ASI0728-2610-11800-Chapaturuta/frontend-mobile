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
  final int role; // 0=Traveller, 2=Driver, 3=Admin

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
    this.role = 0,
  });

  String get fullName {
    final full = '$name $lastName'.trim();
    return full.isNotEmpty ? full : username;
  }

  String get roleLabel {
    switch (role) {
      case 2:
        return 'Conductor';
      case 3:
        return 'Administrador';
      default:
        return 'Pasajero';
    }
  }
}
