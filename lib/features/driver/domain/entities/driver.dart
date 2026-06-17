class Driver {
  final int id;
  final int fkIdUser;
  final String firstName;
  final String lastName;
  final String documentNumber;
  final String phone;
  final String? photoUrl;
  final String licenseNumber;
  final String licenseCategory;
  final String vehiclePlate;
  final String vehicleBrand;
  final String vehicleModel;
  final int vehicleYear;
  final int vehicleCapacity;
  final String vehicleType;
  final bool isAvailable;

  const Driver({
    required this.id,
    required this.fkIdUser,
    required this.firstName,
    required this.lastName,
    required this.documentNumber,
    required this.phone,
    this.photoUrl,
    required this.licenseNumber,
    required this.licenseCategory,
    required this.vehiclePlate,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.vehicleCapacity,
    required this.vehicleType,
    this.isAvailable = false,
  });

  String get fullName => '$firstName $lastName';
}
