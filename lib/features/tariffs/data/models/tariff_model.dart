/// Maps the backend `TariffResource` / `CreateTariffResource` / `UpdateTariffResource`.
///
/// `availableDays` is kept as weekday indices matching .NET `DayOfWeek`
/// (Sunday=0 … Saturday=6). The API serializes them as names ("Monday", …) but
/// System.Text.Json also accepts the numeric form, so we send ints and parse both.
class TariffModel {
  final int id;
  final int fkIdDriver;
  final double baseFare;
  final double pricePerKm;
  final double pricePerMinute;
  final double minFare;
  final String currency;
  final List<int> availableDays;
  final bool isActive;

  const TariffModel({
    this.id = 0,
    required this.fkIdDriver,
    required this.baseFare,
    required this.pricePerKm,
    required this.pricePerMinute,
    required this.minFare,
    this.currency = 'PEN',
    this.availableDays = const [],
    this.isActive = true,
  });

  factory TariffModel.fromJson(Map<String, dynamic> json) {
    return TariffModel(
      id: _int(json['id']),
      fkIdDriver: _int(json['fkIdDriver']),
      baseFare: _double(json['baseFare']),
      pricePerKm: _double(json['pricePerKm']),
      pricePerMinute: _double(json['pricePerMinute']),
      minFare: _double(json['minFare']),
      currency: (json['currency'] ?? 'PEN').toString(),
      availableDays: _parseDays(json['availableDays']),
      isActive: json['isActive'] is bool ? json['isActive'] : true,
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'fkIdDriver': fkIdDriver,
        'baseFare': baseFare,
        'pricePerKm': pricePerKm,
        'pricePerMinute': pricePerMinute,
        'minFare': minFare,
        'currency': currency,
        'availableDays': availableDays,
      };

  Map<String, dynamic> toUpdateJson() => {
        'baseFare': baseFare,
        'pricePerKm': pricePerKm,
        'pricePerMinute': pricePerMinute,
        'minFare': minFare,
        'availableDays': availableDays,
      };

  TariffModel copyWith({
    int? id,
    int? fkIdDriver,
    double? baseFare,
    double? pricePerKm,
    double? pricePerMinute,
    double? minFare,
    String? currency,
    List<int>? availableDays,
    bool? isActive,
  }) {
    return TariffModel(
      id: id ?? this.id,
      fkIdDriver: fkIdDriver ?? this.fkIdDriver,
      baseFare: baseFare ?? this.baseFare,
      pricePerKm: pricePerKm ?? this.pricePerKm,
      pricePerMinute: pricePerMinute ?? this.pricePerMinute,
      minFare: minFare ?? this.minFare,
      currency: currency ?? this.currency,
      availableDays: availableDays ?? this.availableDays,
      isActive: isActive ?? this.isActive,
    );
  }

  static const List<String> _dayNames = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
  ];

  static List<int> _parseDays(dynamic value) {
    if (value is! List) return const [];
    final days = <int>[];
    for (final item in value) {
      if (item is int && item >= 0 && item <= 6) {
        days.add(item);
      } else if (item is String) {
        final asInt = int.tryParse(item);
        if (asInt != null && asInt >= 0 && asInt <= 6) {
          days.add(asInt);
        } else {
          final idx = _dayNames.indexWhere((d) => d.toLowerCase() == item.toLowerCase());
          if (idx >= 0) days.add(idx);
        }
      }
    }
    days.sort();
    return days;
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

/// Maps the backend `RouteDurationResource`.
class RouteDurationModel {
  final int id;
  final int fkIdTariff;
  final int fkIdRoute;
  final int estimatedMinutes;

  const RouteDurationModel({
    required this.id,
    required this.fkIdTariff,
    required this.fkIdRoute,
    required this.estimatedMinutes,
  });

  factory RouteDurationModel.fromJson(Map<String, dynamic> json) {
    return RouteDurationModel(
      id: TariffModel._int(json['id']),
      fkIdTariff: TariffModel._int(json['fkIdTariff']),
      fkIdRoute: TariffModel._int(json['fkIdRoute']),
      estimatedMinutes: TariffModel._int(json['estimatedMinutes']),
    );
  }
}
