class DistrictOption {
  final int id;
  final String name;
  final String province;
  final String region;

  const DistrictOption({
    required this.id,
    required this.name,
    this.province = '',
    this.region = '',
  });

  String get label {
    final parts = [name, province, region].where((p) => p.isNotEmpty).toList();
    return parts.join(', ');
  }

  factory DistrictOption.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    String asString(dynamic v) => v?.toString() ?? '';

    return DistrictOption(
      id: parseInt(json['id'] ?? json['districtId']),
      name: asString(json['name'] ?? json['district'] ?? json['districtName']),
      province: asString(json['provinceName'] ?? json['province']),
      region: asString(json['regionName'] ?? json['region']),
    );
  }
}
