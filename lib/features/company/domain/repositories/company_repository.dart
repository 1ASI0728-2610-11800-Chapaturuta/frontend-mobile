import 'dart:typed_data';

import '../entities/company.dart';

abstract class CompanyRepository {
  Future<Company?> getCompanyForUser(String userId);
  Future<Company> getCompany(int id);
  Future<Company> createCompany({
    required String userId,
    required String name,
    required String ruc,
    required String phone,
    required String email,
    required String address,
    required String description,
    Uint8List? logoBytes,
    String? logoFileName,
  });
  Future<Company> updateCompany(Company company);
  Future<CompanyStats> getStats(int companyId);
}

class CompanyStats {
  final int stops;
  final int routes;
  final int tripsLastMonth;

  const CompanyStats({
    this.stops = 0,
    this.routes = 0,
    this.tripsLastMonth = 0,
  });
}
