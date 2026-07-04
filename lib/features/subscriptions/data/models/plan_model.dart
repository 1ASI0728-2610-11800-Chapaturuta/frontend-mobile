/// Maps the backend `PlanResource` (`/api/v1/plans`).
class PlanModel {
  final int id;
  final String name;
  final String planType; // Free | Premium
  final String targetRole; // Traveller | Driver | Both
  final double price;
  final String currency;
  final String billingCycle; // Monthly | Yearly
  final String benefits;
  final int? discoveryQuota; // null = unlimited
  final bool isActive;

  const PlanModel({
    required this.id,
    required this.name,
    required this.planType,
    required this.targetRole,
    required this.price,
    required this.currency,
    required this.billingCycle,
    required this.benefits,
    this.discoveryQuota,
    required this.isActive,
  });

  bool get isPremium => planType.toLowerCase() == 'premium';
  bool get isFree => !isPremium;

  /// Benefits are stored comma-separated; split for a checklist UI.
  List<String> get benefitList => benefits
      .split(RegExp(r'[,;\n]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  String get billingLabel => billingCycle.toLowerCase() == 'yearly' ? '/año' : '/mes';

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: _int(json['id']),
      name: (json['name'] ?? '').toString(),
      planType: (json['planType'] ?? 'Free').toString(),
      targetRole: (json['targetRole'] ?? 'Both').toString(),
      price: _double(json['price']),
      currency: (json['currency'] ?? 'PEN').toString(),
      billingCycle: (json['billingCycle'] ?? 'Monthly').toString(),
      benefits: (json['benefits'] ?? '').toString(),
      discoveryQuota: json['discoveryQuota'] != null ? _int(json['discoveryQuota']) : null,
      isActive: json['isActive'] is bool ? json['isActive'] : true,
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
