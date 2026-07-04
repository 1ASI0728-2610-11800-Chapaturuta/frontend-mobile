/// Maps the backend `TripResource` (raw trip aggregate), returned by the
/// create/publish/assign-driver/start/complete/cancel endpoints and GET /trips/{id}.
class TripSummaryModel {
  final int id;
  final int fkIdUser;
  final int? fkIdDriver;
  final int fkIdRoute;
  final int fkIdOriginStop;
  final int fkIdDestinationStop;
  final DateTime startTime;
  final DateTime? endTime;
  final double? price;
  final String status;
  final int availableSeats;

  const TripSummaryModel({
    required this.id,
    required this.fkIdUser,
    this.fkIdDriver,
    required this.fkIdRoute,
    required this.fkIdOriginStop,
    required this.fkIdDestinationStop,
    required this.startTime,
    this.endTime,
    this.price,
    required this.status,
    required this.availableSeats,
  });

  factory TripSummaryModel.fromJson(Map<String, dynamic> json) {
    return TripSummaryModel(
      id: _int(json['id']),
      fkIdUser: _int(json['fkIdUser']),
      fkIdDriver: json['fkIdDriver'] != null ? _int(json['fkIdDriver']) : null,
      fkIdRoute: _int(json['fkIdRoute']),
      fkIdOriginStop: _int(json['fkIdOriginStop']),
      fkIdDestinationStop: _int(json['fkIdDestinationStop']),
      startTime: DateTime.tryParse(json['startTime']?.toString() ?? '') ?? DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime'].toString()) : null,
      price: json['price'] != null ? _double(json['price']) : null,
      status: json['status']?.toString() ?? 'Pending',
      availableSeats: _int(json['availableSeats']),
    );
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _double(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}
