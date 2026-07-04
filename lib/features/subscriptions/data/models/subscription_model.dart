/// Maps the backend `SubscriptionResource` (`/api/v1/subscriptions`).
class SubscriptionModel {
  final int id;
  final int fkIdUser;
  final int fkIdPlan;
  final String status; // Active | Expired | Cancelled | PendingPayment
  final DateTime startsAt;
  final DateTime endsAt;
  final bool autoRenew;
  final int? fkIdPayment;
  final int discoveryUsageInCycle;

  const SubscriptionModel({
    required this.id,
    required this.fkIdUser,
    required this.fkIdPlan,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.autoRenew,
    this.fkIdPayment,
    required this.discoveryUsageInCycle,
  });

  bool get isActive => status == 'Active';
  bool get isPendingPayment => status == 'PendingPayment';

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: _int(json['id']),
      fkIdUser: _int(json['fkIdUser']),
      fkIdPlan: _int(json['fkIdPlan']),
      status: (json['status'] ?? 'PendingPayment').toString(),
      startsAt: DateTime.tryParse(json['startsAt']?.toString() ?? '') ?? DateTime.now(),
      endsAt: DateTime.tryParse(json['endsAt']?.toString() ?? '') ?? DateTime.now(),
      autoRenew: json['autoRenew'] is bool ? json['autoRenew'] : false,
      fkIdPayment: json['fkIdPayment'] != null ? _int(json['fkIdPayment']) : null,
      discoveryUsageInCycle: _int(json['discoveryUsageInCycle']),
    );
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
