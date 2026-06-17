import 'package:flutter/material.dart';
import '../../domain/entities/driver.dart';
import '../../domain/repositories/driver_repository.dart';

class DriverProvider with ChangeNotifier {
  final DriverRepository repository;

  Driver? _driver;
  bool _isLoading = false;
  String? _error;

  DriverProvider({required this.repository});

  Driver? get driver => _driver;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasDriver => _driver != null;

  Future<Driver?> loadForUser(String userId) async {
    _setLoading(true);
    try {
      _driver = await repository.getDriverByUser(userId);
      _error = null;
      _setLoading(false);
      return _driver;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return null;
    }
  }

  Future<bool> createDriver({
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
  }) async {
    _setLoading(true);
    try {
      _driver = await repository.createDriver(
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
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
