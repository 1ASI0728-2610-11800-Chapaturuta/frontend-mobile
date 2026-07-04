// Client models for the AI assistant response (`POST /discovery/assistant`).
// The journey graph is the source of truth on the backend; these just render it.

class StopRef {
  final int id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;

  const StopRef({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
  });

  factory StopRef.fromJson(Map<String, dynamic> json) {
    return StopRef(
      id: _int(json['id']),
      name: (json['name'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
    );
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double? _double(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}

/// A leg of an itinerary: a "ride" on a route or a "walk" transfer.
class JourneySegment {
  final String kind; // "ride" | "walk"
  final StopRef from;
  final StopRef to;
  final int? routeId;
  final double? price;
  final double? meters;
  final double? etaSeconds;

  const JourneySegment({
    required this.kind,
    required this.from,
    required this.to,
    this.routeId,
    this.price,
    this.meters,
    this.etaSeconds,
  });

  bool get isRide => kind == 'ride';

  String? get etaLabel {
    if (etaSeconds == null || etaSeconds! <= 0) return null;
    return '${(etaSeconds! / 60).round()} min';
  }

  factory JourneySegment.fromJson(Map<String, dynamic> json) {
    return JourneySegment(
      kind: (json['kind'] ?? 'ride').toString(),
      from: StopRef.fromJson((json['from'] ?? {}) as Map<String, dynamic>),
      to: StopRef.fromJson((json['to'] ?? {}) as Map<String, dynamic>),
      routeId: _int(json['routeId']),
      price: _double(json['price']),
      meters: _double(json['meters']),
      etaSeconds: _double(json['etaSeconds']),
    );
  }

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double? _double(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}

class JourneyItinerary {
  final List<JourneySegment> segments;
  final int transfers;
  final double totalPrice;
  final double? totalEtaSeconds;

  const JourneyItinerary({
    required this.segments,
    required this.transfers,
    required this.totalPrice,
    this.totalEtaSeconds,
  });

  String? get totalEtaLabel {
    if (totalEtaSeconds == null || totalEtaSeconds! <= 0) return null;
    return '${(totalEtaSeconds! / 60).round()} min';
  }

  factory JourneyItinerary.fromJson(Map<String, dynamic> json) {
    final segs = (json['segments'] is List)
        ? (json['segments'] as List)
            .whereType<Map<String, dynamic>>()
            .map(JourneySegment.fromJson)
            .toList()
        : <JourneySegment>[];
    return JourneyItinerary(
      segments: segs,
      transfers: _int(json['transfers']),
      totalPrice: _double(json['totalPrice']),
      totalEtaSeconds: json['totalEtaSeconds'] != null ? _double(json['totalEtaSeconds']) : null,
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

/// Full assistant reply: narrated text + any itineraries the graph produced.
class AssistantReply {
  final String reply;
  final List<JourneyItinerary> itineraries;

  const AssistantReply({required this.reply, required this.itineraries});

  factory AssistantReply.fromJson(Map<String, dynamic> json) {
    final its = (json['itineraries'] is List)
        ? (json['itineraries'] as List)
            .whereType<Map<String, dynamic>>()
            .map(JourneyItinerary.fromJson)
            .toList()
        : <JourneyItinerary>[];
    return AssistantReply(
      reply: (json['reply'] ?? '').toString(),
      itineraries: its,
    );
  }
}
