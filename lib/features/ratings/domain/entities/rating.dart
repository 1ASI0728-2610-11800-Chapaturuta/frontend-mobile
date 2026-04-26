class Rating {
  final int id;
  final int routeId;
  final int userId;
  final double score;
  final String? comment;
  final DateTime createdAt;

  const Rating({
    required this.id,
    required this.routeId,
    required this.userId,
    required this.score,
    this.comment,
    required this.createdAt,
  });
}
