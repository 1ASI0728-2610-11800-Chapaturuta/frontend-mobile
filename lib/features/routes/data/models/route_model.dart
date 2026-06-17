import '../../domain/entities/route.dart';

class TransportRouteModel extends TransportRoute {
  TransportRouteModel({
    required super.id,
    required super.name,
    required super.price,
    required super.duration,
    required super.distance,
    required super.state,
    super.polylineRoute,
    required super.driverId,
    super.frequency,
    super.stops,
    super.originAddress,
    super.destinationAddress,
  });

  factory TransportRouteModel.fromJson(Map<String, dynamic> json) {
    final parsedStops = _parseStops(json['stops']);
    return TransportRouteModel(
      id: _parseInt(json['id']),
      name: _asString(json['name'])
          ?? _buildNameFromStops(json['stops'])
          ?? '',
      price: _parseDouble(json['price']),
      duration: _formatMinutes(json['duration']),
      distance: _formatMeters(json['distanceMeters'] ?? json['distance']),
      state: _asString(json['status']) ?? _asString(json['state']) ?? 'Active',
      polylineRoute: _asString(json['geometry']) ?? _asString(json['polylineRoute']),
      driverId: _parseInt(json['driverId']),
      frequency: _parseInt(json['frequency']),
      stops: parsedStops,
      originAddress: _asString(json['originAddress']),
      destinationAddress: _asString(json['destinationAddress']),
    );
  }

  static List<RouteStop> _parseStops(dynamic stops) {
    if (stops is! List) return [];
    return stops
        .whereType<Map<String, dynamic>>()
        .map((s) => RouteStop.fromJson(s))
        .toList();
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static String? _asString(dynamic v) => v?.toString();

  static String _formatMinutes(dynamic v) {
    final n = _parseInt(v);
    if (n <= 0) return '';
    return '$n min';
  }

  static String _formatMeters(dynamic v) {
    final m = _parseDouble(v);
    if (m <= 0) return '';
    if (m >= 1000) return '${(m / 1000).toStringAsFixed(1)} km';
    return '${m.toStringAsFixed(0)} m';
  }

  static String? _buildNameFromStops(dynamic stops) {
    if (stops is! List || stops.isEmpty) return null;
    final first = stops.first;
    final last = stops.last;
    final a = first is Map ? _asString(first['name']) : null;
    final b = last is Map ? _asString(last['name']) : null;
    if (a == null && b == null) return null;
    return '${a ?? '?'} - ${b ?? '?'}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration': duration,
      'distance': distance,
      'state': state,
      'polylineRoute': polylineRoute,
      'driverId': driverId,
      'originAddress': originAddress,
      'destinationAddress': destinationAddress,
    };
  }
}
