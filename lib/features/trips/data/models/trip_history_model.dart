/// Maps the backend `TripHistoryResource` (enriched trip with resolved names).
/// Returned by GET /trips/{user|driver}/{id}/history, /trips/available and /trips/joinable.
class TripHistoryModel {
  final int id;
  final String routeName;
  final String originName;
  final String destinationName;
  final String driverName;
  final String passengerName;
  final DateTime startTime;
  final DateTime? endTime;
  final double? price;
  final String status;
  final int fkIdRoute;
  final int availableSeats;

  // Present only in passenger-facing history (the caller's own reservation on the trip).
  final int? myReservationId;
  final String? myReservationStatus;
  final int? myReservationSeats;

  const TripHistoryModel({
    required this.id,
    required this.routeName,
    required this.originName,
    required this.destinationName,
    required this.driverName,
    required this.passengerName,
    required this.startTime,
    this.endTime,
    this.price,
    required this.status,
    required this.fkIdRoute,
    required this.availableSeats,
    this.myReservationId,
    this.myReservationStatus,
    this.myReservationSeats,
  });

  factory TripHistoryModel.fromJson(Map<String, dynamic> json) {
    return TripHistoryModel(
      id: _int(json['id']),
      routeName: _str(json['routeName'], 'Ruta desconocida'),
      originName: _str(json['originName'], ''),
      destinationName: _str(json['destinationName'], ''),
      driverName: _str(json['driverName'], ''),
      passengerName: _str(json['passengerName'], ''),
      startTime: DateTime.tryParse(json['startTime']?.toString() ?? '') ?? DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime'].toString()) : null,
      price: json['price'] != null ? _double(json['price']) : null,
      status: _str(json['status'], 'Pending'),
      fkIdRoute: _int(json['fkIdRoute']),
      availableSeats: _int(json['availableSeats']),
      myReservationId: json['myReservationId'] != null ? _int(json['myReservationId']) : null,
      myReservationStatus: json['myReservationStatus']?.toString(),
      myReservationSeats:
          json['myReservationSeats'] != null ? _int(json['myReservationSeats']) : null,
    );
  }

  /// Lowercased, whitespace/underscore-free status for branching (matches web `normalizeStatus`).
  String get statusKey => status.toLowerCase().replaceAll(RegExp(r'[\s_]'), '');

  bool get canStart => statusKey == 'pending';
  bool get canComplete => statusKey == 'inprogress';
  bool get canCancel => statusKey == 'pending' || statusKey == 'inprogress';

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

  static String _str(dynamic v, String fallback) {
    final t = v?.toString();
    return (t == null || t.isEmpty) ? fallback : t;
  }
}
