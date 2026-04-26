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
    super.originAddress,
    super.destinationAddress,
  });

  factory TransportRouteModel.fromJson(Map<String, dynamic> json) {
    return TransportRouteModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: _parsePrice(json['price']),
      duration: json['duration'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      state: json['state'] as String? ?? 'Active',
      polylineRoute: json['polylineRoute'] as String?,
      driverId: json['driverId'] as int? ?? 0,
      originAddress: json['originAddress'] as String?,
      destinationAddress: json['destinationAddress'] as String?,
    );
  }

  /// Helper para parsear el precio que viene del backend
  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) return double.tryParse(price) ?? 0.0;
    return 0.0;
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