import '../../../routes/data/models/route_model.dart';

/// One entry from GET /discovery/search: a matching route plus optional OSRM estimates
/// (present when both origin and destination were provided).
class SearchResultModel {
  final TransportRouteModel route;
  final double? estimatedDistanceMeters;
  final int? estimatedDurationSeconds;

  const SearchResultModel({
    required this.route,
    this.estimatedDistanceMeters,
    this.estimatedDurationSeconds,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    // The backend wraps the route under a `route` key; older shapes may inline it.
    final routeJson = json['route'] is Map<String, dynamic>
        ? json['route'] as Map<String, dynamic>
        : json;
    return SearchResultModel(
      route: TransportRouteModel.fromJson(routeJson),
      estimatedDistanceMeters: _double(json['estimatedDistanceMeters']),
      estimatedDurationSeconds: _int(json['estimatedDurationSeconds']),
    );
  }

  String? get estimatedDurationLabel {
    if (estimatedDurationSeconds == null || estimatedDurationSeconds! <= 0) return null;
    final minutes = (estimatedDurationSeconds! / 60).round();
    return '$minutes min';
  }

  String? get estimatedDistanceLabel {
    if (estimatedDistanceMeters == null || estimatedDistanceMeters! <= 0) return null;
    final m = estimatedDistanceMeters!;
    return m >= 1000 ? '${(m / 1000).toStringAsFixed(1)} km' : '${m.toStringAsFixed(0)} m';
  }

  static double? _double(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}
