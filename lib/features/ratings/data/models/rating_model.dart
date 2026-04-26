import '../../domain/entities/rating.dart';

class RatingModel extends Rating {
  const RatingModel({
    required super.id,
    required super.routeId,
    required super.userId,
    required super.score,
    super.comment,
    required super.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as int,
      routeId: json['routeId'] as int,
      userId: json['userId'] as int,
      score: (json['score'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'routeId': routeId,
    'userId': userId,
    'score': score,
    'comment': comment,
  };
}
