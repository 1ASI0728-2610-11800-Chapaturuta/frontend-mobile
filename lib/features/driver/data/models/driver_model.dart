import '../../domain/entities/driver.dart';

class DriverModel extends Driver {
  const DriverModel({
    required super.id,
    required super.fkIdUser,
    required super.firstName,
    required super.lastName,
    required super.documentNumber,
    required super.phone,
    super.photoUrl,
    required super.licenseNumber,
    required super.licenseCategory,
    required super.vehiclePlate,
    required super.vehicleBrand,
    required super.vehicleModel,
    required super.vehicleYear,
    required super.vehicleCapacity,
    required super.vehicleType,
    super.isAvailable,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: _parseInt(json['id']),
      fkIdUser: _parseInt(json['fkIdUser']),
      firstName: _str(json['firstName']),
      lastName: _str(json['lastName']),
      documentNumber: _str(json['documentNumber']),
      phone: _str(json['phone']),
      photoUrl: _nullable(json['photoUrl']),
      licenseNumber: _str(json['licenseNumber']),
      licenseCategory: _str(json['licenseCategory']),
      vehiclePlate: _str(json['vehiclePlate']),
      vehicleBrand: _str(json['vehicleBrand']),
      vehicleModel: _str(json['vehicleModel']),
      vehicleYear: _parseInt(json['vehicleYear']),
      vehicleCapacity: _parseInt(json['vehicleCapacity']),
      vehicleType: _str(json['vehicleType']),
      isAvailable: json['isAvailable'] is bool ? json['isAvailable'] : false,
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static String _str(dynamic v) => v?.toString() ?? '';

  static String? _nullable(dynamic v) {
    final t = v?.toString();
    return (t == null || t.isEmpty) ? null : t;
  }
}
