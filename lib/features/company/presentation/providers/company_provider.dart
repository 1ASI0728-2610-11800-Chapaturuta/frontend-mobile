import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';

class CompanyProvider with ChangeNotifier {
  final CompanyRepository repository;

  Company? _company;
  CompanyStats _stats = const CompanyStats();
  bool _isLoading = false;
  String? _error;

  CompanyProvider({required this.repository});

  Company? get company => _company;
  CompanyStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCompany => _company != null;

  Future<Company?> loadForUser(String userId) async {
    _setLoading(true);
    try {
      _company = await repository.getCompanyForUser(userId);
      if (_company != null) {
        _stats = await repository.getStats(_company!.id);
      }
      _error = null;
      _setLoading(false);
      return _company;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return null;
    }
  }

  Future<void> refreshStats() async {
    final company = _company;
    if (company == null) return;
    _stats = await repository.getStats(company.id);
    notifyListeners();
  }

  Future<bool> createCompany({
    required String userId,
    required String name,
    required String ruc,
    required String phone,
    required String email,
    required String address,
    required String description,
    Uint8List? logoBytes,
    String? logoFileName,
  }) async {
    _setLoading(true);
    try {
      _company = await repository.createCompany(
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
      _stats = const CompanyStats();
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateCompany(Company company) async {
    _setLoading(true);
    try {
      _company = await repository.updateCompany(company);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
