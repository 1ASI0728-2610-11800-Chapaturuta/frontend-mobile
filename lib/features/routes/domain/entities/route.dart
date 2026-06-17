class RouteStop {
  final int id;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int? fkDriverId;

  const RouteStop({
    required this.id,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.fkDriverId,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      id: (json['id'] is int) ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      fkDriverId: _toInt(json['fk_driver_id'] ?? json['fkIdDriver'] ?? json['fkDriverId']),
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}

class TransportRoute {
  final int id;
  final String name;
  final double price;
  final String duration;
  final String distance;
  final String state;
  final String? polylineRoute;
  final int driverId;
  final int frequency;
  final List<RouteStop> stops;

  final String? originAddress;
  final String? destinationAddress;

  TransportRoute({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.distance,
    required this.state,
    this.polylineRoute,
    required this.driverId,
    this.frequency = 0,
    this.stops = const [],
    this.originAddress,
    this.destinationAddress,
  });

  String get origin {
    if (originAddress != null) return originAddress!;
    if (stops.isNotEmpty) return stops.first.name;
    final parts = name.split('-');
    return parts.isNotEmpty ? parts[0].trim() : 'Origen';
  }

  String get destination {
    if (destinationAddress != null) return destinationAddress!;
    if (stops.length > 1) return stops.last.name;
    final parts = name.split('-');
    return parts.length > 1 ? parts[1].trim() : 'Destino';
  }
}
