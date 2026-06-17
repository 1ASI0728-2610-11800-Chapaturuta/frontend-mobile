class CompanyStopModel {
  final int id;
  final int driverId;
  final int fkIdDistrict;
  final String name;
  final String address;
  final String reference;
  final String districtLabel;
  final String phone;
  final String googleMapsUrl;
  final double latitude;
  final double longitude;
  final String? imageUrl;

  const CompanyStopModel({
    required this.id,
    required this.driverId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.fkIdDistrict = 0,
    this.reference = '',
    this.districtLabel = '',
    this.phone = '',
    this.googleMapsUrl = '',
    this.imageUrl,
  });

  factory CompanyStopModel.fromJson(Map<String, dynamic> json) {
    return CompanyStopModel(
      id: _parseInt(json['id'] ?? json['stopId']),
      driverId: _parseInt(json['fkIdDriver'] ?? json['driverId']),
      fkIdDistrict: _parseInt(json['fkIdDistrict'] ?? json['districtId']),
      name: _asString(json['name']),
      address: _asString(json['address']),
      reference: _asString(json['reference']),
      districtLabel: _asString(json['districtName'] ?? json['district']),
      phone: _asString(json['phone']),
      googleMapsUrl: _asString(json['googleMapsUrl']),
      latitude: _parseDouble(json['latitude'] ?? json['lat']),
      longitude: _parseDouble(json['longitude'] ?? json['lng']),
      imageUrl: _nullable(json['imageUrl'] ?? json['image']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static String _asString(dynamic value) => value?.toString() ?? '';

  static String? _nullable(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }

  /// Form fields for `POST /api/stops` (CreateStopFormResource).
  Map<String, String> toFields() {
    final gmaps = googleMapsUrl.isNotEmpty
        ? googleMapsUrl
        : (latitude != 0 || longitude != 0)
            ? 'https://maps.google.com/?q=$latitude,$longitude'
            : '';
    return {
      'Name': name,
      'Address': address,
      'Reference': reference,
      'FkIdDriver': driverId.toString(),
      'FkIdDistrict': fkIdDistrict.toString(),
      'GoogleMapsUrl': gmaps,
      'Latitude': latitude.toString(),
      'Longitude': longitude.toString(),
    };
  }

  /// JSON body for `PUT /api/stops/{id}` (UpdateStopResource).
  Map<String, dynamic> toUpdateJson() {
    final gmaps = googleMapsUrl.isNotEmpty
        ? googleMapsUrl
        : (latitude != 0 || longitude != 0)
            ? 'https://maps.google.com/?q=$latitude,$longitude'
            : '';
    return {
      'id': id,
      'name': name,
      'googleMapsUrl': gmaps,
      'imageUrl': imageUrl ?? '',
      'fkIdDriver': driverId,
      'address': address,
      'reference': reference,
      'fkIdDistrict': fkIdDistrict,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  CompanyStopModel copyWith({
    int? id,
    int? driverId,
    int? fkIdDistrict,
    String? name,
    String? address,
    String? reference,
    String? districtLabel,
    String? phone,
    String? googleMapsUrl,
    double? latitude,
    double? longitude,
    String? imageUrl,
  }) {
    return CompanyStopModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      fkIdDistrict: fkIdDistrict ?? this.fkIdDistrict,
      name: name ?? this.name,
      address: address ?? this.address,
      reference: reference ?? this.reference,
      districtLabel: districtLabel ?? this.districtLabel,
      phone: phone ?? this.phone,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
