/// Maps the backend `NearbyStopResource` from GET /discovery/nearby.
class NearbyStopModel {
  final int id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final int fkIdDriver;
  final int fkIdDistrict;

  const NearbyStopModel({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    required this.fkIdDriver,
    required this.fkIdDistrict,
  });

  factory NearbyStopModel.fromJson(Map<String, dynamic> json) {
    return NearbyStopModel(
      id: _int(json['id']),
      name: (json['name'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      fkIdDriver: _int(json['fkIdDriver']),
      fkIdDistrict: _int(json['fkIdDistrict']),
    );
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double? _double(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}
