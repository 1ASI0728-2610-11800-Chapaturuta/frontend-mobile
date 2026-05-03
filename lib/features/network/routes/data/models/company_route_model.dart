class RouteScheduleModel {
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final bool enabled;

  const RouteScheduleModel({
    required this.dayOfWeek,
    this.startTime = '06:00',
    this.endTime = '22:00',
    this.enabled = true,
  });

  factory RouteScheduleModel.fromJson(Map<String, dynamic> json) {
    return RouteScheduleModel(
      dayOfWeek: (json['dayOfWeek'] ?? '').toString(),
      startTime: (json['startTime'] ?? '06:00').toString(),
      endTime: (json['endTime'] ?? '22:00').toString(),
      enabled: json['enabled'] is bool ? json['enabled'] : true,
    );
  }

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'enabled': enabled,
      };

  RouteScheduleModel copyWith({
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? enabled,
  }) {
    return RouteScheduleModel(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      enabled: enabled ?? this.enabled,
    );
  }
}

class CompanyRouteModel {
  final int id;
  final int companyId;
  final String name;
  final double price;
  final int duration;
  final int frequency;
  final String status;
  final String? geometry;
  final List<int> stopIds;
  final List<RouteScheduleModel> schedules;

  const CompanyRouteModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.price,
    this.duration = 0,
    this.frequency = 0,
    this.status = 'Active',
    this.geometry,
    this.stopIds = const [],
    this.schedules = const [],
  });

  factory CompanyRouteModel.fromJson(Map<String, dynamic> json) {
    return CompanyRouteModel(
      id: _parseInt(json['id'] ?? json['routeId']),
      companyId: _parseInt(json['companyId']),
      name: _asString(json['name']) == '' ? _nameFromStops(json['stops']) : _asString(json['name']),
      price: _parseDouble(json['price']),
      duration: _parseInt(json['duration']),
      frequency: _parseInt(json['frequency']),
      status: _asString(json['status']).isEmpty ? 'Active' : _asString(json['status']),
      geometry: _nullable(json['geometry'] ?? json['polylineRoute']),
      stopIds: _parseStopIds(json['stopIds'] ?? json['stops']),
      schedules: _parseSchedules(json['schedules']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static String _asString(dynamic value) => value?.toString() ?? '';

  static String? _nullable(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }

  static List<int> _parseStopIds(dynamic value) {
    if (value is List) {
      return value.map((item) {
        if (item is Map<String, dynamic>) return _parseInt(item['id'] ?? item['stopId']);
        return _parseInt(item);
      }).where((id) => id > 0).toList();
    }
    return [];
  }

  static List<RouteScheduleModel> _parseSchedules(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(RouteScheduleModel.fromJson)
        .toList();
  }

  static String _nameFromStops(dynamic stops) {
    if (stops is! List || stops.isEmpty) return 'Ruta';
    final first = stops.first;
    final last = stops.last;
    final a = first is Map<String, dynamic> ? _asString(first['name']) : '';
    final b = last is Map<String, dynamic> ? _asString(last['name']) : '';
    if (a.isEmpty && b.isEmpty) return 'Ruta';
    return '$a - $b';
  }

  /// Body para `POST /api/routes` (CreateFullRouteResource).
  Map<String, dynamic> toCreateJson() {
    return {
      'frequency': frequency,
      'price': price,
      'duration': duration,
      'stopsIds': stopIds,
      'schedules': schedules.map((s) => s.toJson()).toList(),
    };
  }

  /// Body para `PUT /api/routes/{id}` (UpdateRouteResource).
  Map<String, dynamic> toUpdateJson() => toCreateJson();

  CompanyRouteModel copyWith({
    int? id,
    int? companyId,
    String? name,
    double? price,
    int? duration,
    int? frequency,
    String? status,
    String? geometry,
    List<int>? stopIds,
    List<RouteScheduleModel>? schedules,
  }) {
    return CompanyRouteModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
      geometry: geometry ?? this.geometry,
      stopIds: stopIds ?? this.stopIds,
      schedules: schedules ?? this.schedules,
    );
  }
}
