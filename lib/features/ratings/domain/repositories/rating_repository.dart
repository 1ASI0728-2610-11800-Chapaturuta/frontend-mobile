import '../entities/rating.dart';

abstract class RatingRepository {
  Future<List<Rating>> getRatingsForRoute(int routeId);
  Future<Rating> createRating({required int routeId, required double score, String? comment});
}
