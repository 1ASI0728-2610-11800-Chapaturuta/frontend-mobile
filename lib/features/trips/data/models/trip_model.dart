import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.routeId,
    required super.routeName,
    required super.userId,
    required super.date,
    required super.price,
    required super.status,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as int,
      routeId: json['routeId'] as int,
      routeName: json['routeName'] as String? ?? 'Ruta desconocida',
      userId: json['userId'] as int,
      date: DateTime.parse(json['date'] as String),
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String? ?? 'completed',
    );
  }
}
