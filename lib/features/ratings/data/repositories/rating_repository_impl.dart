import '../../domain/entities/rating.dart';
import '../../domain/repositories/rating_repository.dart';
import '../datasources/rating_api_service.dart';

class RatingRepositoryImpl implements RatingRepository {
  final RatingApiService apiService;

  RatingRepositoryImpl({required this.apiService});

  @override
  Future<List<Rating>> getRatingsForRoute(int routeId) =>
      apiService.getRatingsForRoute(routeId);

  @override
  Future<Rating> createRating({required int routeId, required double score, String? comment}) =>
      apiService.createRating(routeId: routeId, score: score, comment: comment);
}
