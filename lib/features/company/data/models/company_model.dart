import '../../domain/entities/company.dart';

class CompanyModel extends Company {
  const CompanyModel({
    required super.id,
    super.fkIdUser,
    required super.name,
    super.ruc,
    super.phone,
    super.email,
    super.address,
    super.description,
    super.logoUrl,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: _parseInt(json['id'] ?? json['companyId']),
      fkIdUser: _parseInt(json['fkIdUser'] ?? json['fkIdUSer'] ?? json['userId']),
      name: _asString(json['name'] ?? json['businessName']),
      ruc: _asString(json['ruc'] ?? json['taxId']),
      phone: _asString(json['phone']),
      email: _asString(json['email']),
      address: _asString(json['address']),
      description: _asString(json['description']),
      logoUrl: _nullableString(json['logoUrl'] ?? json['logo']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _asString(dynamic value) => value?.toString() ?? '';

  static String? _nullableString(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }

  /// Body que espera `PUT /api/companies/{id}` (UpdateCompanyResource).
  /// El backend valida `id == resource.Id` y exige `fkIdUser`.
  Map<String, dynamic> toUpdateJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl ?? '',
      'fkIdUser': fkIdUser,
      'ruc': ruc,
      'phone': phone,
      'email': email,
      'address': address,
      'description': description,
    };
  }

  CompanyModel copyWith({
    int? id,
    int? fkIdUser,
    String? name,
    String? ruc,
    String? phone,
    String? email,
    String? address,
    String? description,
    String? logoUrl,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      fkIdUser: fkIdUser ?? this.fkIdUser,
      name: name ?? this.name,
      ruc: ruc ?? this.ruc,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}
