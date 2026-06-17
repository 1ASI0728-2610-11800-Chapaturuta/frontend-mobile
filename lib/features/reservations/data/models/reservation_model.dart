class ReservationModel {
  final int id;
  final int fkIdUser;
  final int fkIdTrip;
  final String documentType;
  final String documentNumber;
  final int seats;
  final String status;
  final int? fkIdPayment;
  final DateTime reservedAt;
  final DateTime? confirmedAt;

  // Enriched fields (from trip/route joins)
  final String? routeName;
  final String? originName;
  final String? destinationName;
  final double? price;

  const ReservationModel({
    required this.id,
    required this.fkIdUser,
    required this.fkIdTrip,
    required this.documentType,
    required this.documentNumber,
    required this.seats,
    required this.status,
    this.fkIdPayment,
    required this.reservedAt,
    this.confirmedAt,
    this.routeName,
    this.originName,
    this.destinationName,
    this.price,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: _parseInt(json['id']),
      fkIdUser: _parseInt(json['fkIdUser']),
      fkIdTrip: _parseInt(json['fkIdTrip']),
      documentType: (json['documentType'] ?? 'Dni').toString(),
      documentNumber: (json['documentNumber'] ?? '').toString(),
      seats: _parseInt(json['seats']),
      status: (json['status'] ?? 'Pending').toString(),
      fkIdPayment: json['fkIdPayment'] != null ? _parseInt(json['fkIdPayment']) : null,
      reservedAt: DateTime.tryParse(json['reservedAt']?.toString() ?? '') ?? DateTime.now(),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.tryParse(json['confirmedAt'].toString())
          : null,
      routeName: json['routeName']?.toString(),
      originName: json['originName']?.toString(),
      destinationName: json['destinationName']?.toString(),
      price: json['price'] != null ? _parseDouble(json['price']) : null,
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  String get statusLabel {
    switch (status) {
      case 'Confirmed':
        return 'Confirmada';
      case 'Cancelled':
        return 'Cancelada';
      case 'Completed':
        return 'Completada';
      case 'Refunded':
        return 'Reembolsada';
      default:
        return 'Pendiente';
    }
  }

  bool get canCancel => status == 'Pending' || status == 'Confirmed';
  bool get canConfirm => status == 'Pending';
}
