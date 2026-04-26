import '../../domain/entities/route.dart';
import '../../domain/repositories/route_repository.dart';
import '../datasources/route_api_service.dart';

class RouteRepositoryImpl implements RouteRepository {
  final RouteApiService apiService;

  RouteRepositoryImpl({required this.apiService});

  @override
  Future<List<TransportRoute>> getAllRoutes() async {
    try {
      return await apiService.getAllRoutes();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TransportRoute>> filterRoutes({
    String? region,
    String? province,
    String? district,
    String? locality,
  }) async {
    try {
      final allRoutes = await apiService.getAllRoutes();
      
      return allRoutes.where((route) {
        bool matches = true;
        
        if (region != null && region.isNotEmpty) {
          matches = matches && route.name.toLowerCase().contains(region.toLowerCase());
        }
        if (province != null && province.isNotEmpty) {
          matches = matches && route.name.toLowerCase().contains(province.toLowerCase());
        }
        if (district != null && district.isNotEmpty) {
          matches = matches && route.name.toLowerCase().contains(district.toLowerCase());
        }
        if (locality != null && locality.isNotEmpty) {
          matches = matches && route.name.toLowerCase().contains(locality.toLowerCase());
        }
        
        return matches;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TransportRoute?> getRouteById(String id) async {
    try {
      return await apiService.getRouteById(int.parse(id));
    } catch (e) {
      return null;
    }
  }
}