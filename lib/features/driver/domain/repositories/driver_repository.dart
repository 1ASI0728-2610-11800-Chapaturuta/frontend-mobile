import '../entities/driver.dart';

abstract class DriverRepository {
  Future<Driver?> getDriverByUser(String userId);
  Future<Driver> createDriver({
    required String fkIdUser,
    required String firstName,
    required String lastName,
    required String documentNumber,
    required String phone,
    required String licenseNumber,
    required String licenseCategory,
    required String vehiclePlate,
    required String vehicleBrand,
    required String vehicleModel,
    required int vehicleYear,
    required int vehicleCapacity,
    required String vehicleType,
  });
}
