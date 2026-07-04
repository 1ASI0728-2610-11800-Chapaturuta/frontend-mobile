/// Maps the backend `PaymentResource` (`/api/v1/payments`).
class PaymentModel {
  final int id;
  final int fkIdUser;
  final double amount;
  final String currency;
  final String method; // Yape | Plin | Card | Cash
  final String status; // Pending | Completed | Failed | Refunded | PartiallyRefunded
  final String? externalReference;
  final String referenceType; // Reservation | Subscription
  final int referenceId;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final String? payerName;

  const PaymentModel({
    required this.id,
    required this.fkIdUser,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    this.externalReference,
    required this.referenceType,
    required this.referenceId,
    required this.createdAt,
    this.confirmedAt,
    this.payerName,
  });

  bool get isCompleted => status == 'Completed';
  bool get isPending => status == 'Pending';

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: _int(json['id']),
      fkIdUser: _int(json['fkIdUser']),
      amount: _double(json['amount']),
      currency: (json['currency'] ?? 'PEN').toString(),
      method: (json['method'] ?? '').toString(),
      status: (json['status'] ?? 'Pending').toString(),
      externalReference: json['externalReference']?.toString(),
      referenceType: (json['referenceType'] ?? '').toString(),
      referenceId: _int(json['referenceId']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.tryParse(json['confirmedAt'].toString())
          : null,
      payerName: json['payerName']?.toString(),
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
