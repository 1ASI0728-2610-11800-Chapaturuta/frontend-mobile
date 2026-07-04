import '../../domain/entities/driver.dart';
import '../../domain/repositories/driver_repository.dart';
import '../datasources/driver_api_service.dart';

class DriverRepositoryImpl implements DriverRepository {
  final DriverApiService apiService;

  DriverRepositoryImpl({required this.apiService});

  @override
  Future<Driver?> getDriverByUser(String userId) {
    return apiService.getDriverByUser(userId);
  }

  @override
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
  }) {
    return apiService.createDriver(
      fkIdUser: fkIdUser,
      firstName: firstName,
      lastName: lastName,
      documentNumber: documentNumber,
      phone: phone,
      licenseNumber: licenseNumber,
      licenseCategory: licenseCategory,
      vehiclePlate: vehiclePlate,
      vehicleBrand: vehicleBrand,
      vehicleModel: vehicleModel,
      vehicleYear: vehicleYear,
      vehicleCapacity: vehicleCapacity,
      vehicleType: vehicleType,
    );
  }

  @override
  Future<Driver> toggleAvailability(int driverId) {
    return apiService.toggleAvailability(driverId);
  }
}
