import '../entities/route.dart';

abstract class RouteRepository {
  Future<List<TransportRoute>> getAllRoutes();
  Future<List<TransportRoute>> filterRoutes({
    String? region,
    String? province,
    String? district,
    String? locality,
  });
  Future<TransportRoute?> getRouteById(String id);
}