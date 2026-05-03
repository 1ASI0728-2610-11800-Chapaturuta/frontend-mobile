import 'dart:typed_data';

import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_api_service.dart';
import '../models/company_model.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyApiService apiService;

  CompanyRepositoryImpl({required this.apiService});

  @override
  Future<Company?> getCompanyForUser(String userId) {
    return apiService.getCompanyForUser(userId);
  }

  @override
  Future<Company> getCompany(int id) {
    return apiService.getCompany(id);
  }

  @override
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
  }) {
    return apiService.createCompany(
      userId: userId,
      name: name,
      ruc: ruc,
      phone: phone,
      email: email,
      address: address,
      description: description,
      logoBytes: logoBytes,
      logoFileName: logoFileName,
    );
  }

  @override
  Future<Company> updateCompany(Company company) {
    final model = company is CompanyModel
        ? company
        : CompanyModel(
            id: company.id,
            fkIdUser: company.fkIdUser,
            name: company.name,
            ruc: company.ruc,
            phone: company.phone,
            email: company.email,
            address: company.address,
            description: company.description,
            logoUrl: company.logoUrl,
          );
    return apiService.updateCompany(model);
  }

  @override
  Future<CompanyStats> getStats(int companyId) {
    return apiService.getStats(companyId);
  }
}
