/// Maps the backend `RatingResource` (`/api/ratings`). Ratings are for a driver on a
/// completed trip — not for a route (the old shape was wrong).
class RatingModel {
  final int id;
  final int fkIdUser;
  final int fkIdDriver;
  final int fkIdTrip;
  final int score; // 1..5
  final String? comment;
  final DateTime createdAt;

  const RatingModel({
    required this.id,
    required this.fkIdUser,
    required this.fkIdDriver,
    required this.fkIdTrip,
    required this.score,
    this.comment,
    required this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: _int(json['id']),
      fkIdUser: _int(json['fkIdUser']),
      fkIdDriver: _int(json['fkIdDriver']),
      fkIdTrip: _int(json['fkIdTrip']),
      score: _int(json['score']),
      comment: json['comment']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

/// Maps the backend `RatingSummaryResource` from GET /ratings/driver/{id}/summary.
class RatingSummary {
  final int driverId;
  final double average;
  final int count;

  const RatingSummary({required this.driverId, required this.average, required this.count});

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    return RatingSummary(
      driverId: RatingModel._int(json['driverId']),
      average: _double(json['average']),
      count: RatingModel._int(json['count']),
    );
  }

  static double _double(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}
