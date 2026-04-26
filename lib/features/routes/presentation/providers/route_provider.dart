import 'package:flutter/material.dart';
import '../../domain/entities/route.dart';
import '../../domain/repositories/route_repository.dart';
import '../../data/datasources/route_api_service.dart';

class RouteProvider with ChangeNotifier {
  final RouteRepository repository;
  final RouteApiService? apiService;
  
  List<TransportRoute> _routes = [];
  List<TransportRoute> _filteredRoutes = [];
  
  // 👇 AGREGADO: Lista para guardar los favoritos en memoria
  final List<TransportRoute> _favoriteRoutes = [];

  bool _isLoading = false;
  String? _error;
  
  String? _selectedRegion;
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedLocality;

  RouteProvider({
    required this.repository,
    this.apiService,
  });

  List<TransportRoute> get routes => _filteredRoutes.isEmpty ? _routes : _filteredRoutes;
  
  // 👇 AGREGADO: Getter para leer los favoritos desde la pantalla de favoritos
  List<TransportRoute> get favoriteRoutes => _favoriteRoutes;

  bool get isLoading => _isLoading;
  String? get error => _error;
  
  String? get selectedRegion => _selectedRegion;
  String? get selectedProvince => _selectedProvince;
  String? get selectedDistrict => _selectedDistrict;
  String? get selectedLocality => _selectedLocality;

  void setToken(String token) {
    apiService?.setBearerToken(token);
  }

  // 👇 AGREGADO: Método para saber si una ruta ya es favorita
  bool isFavorite(int id) {
    return _favoriteRoutes.any((route) => route.id == id);
  }

  // 👇 AGREGADO: Método para agregar o quitar de favoritos
  void toggleFavorite(TransportRoute route) {
    final exists = _favoriteRoutes.any((r) => r.id == route.id);
    if (exists) {
      _favoriteRoutes.removeWhere((r) => r.id == route.id);
    } else {
      _favoriteRoutes.add(route);
    }
    notifyListeners();
  }

  Future<void> loadRoutes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _routes = await repository.getAllRoutes();
      _filteredRoutes = _routes;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterRoutes() async {
    if (_selectedRegion == null && 
        _selectedProvince == null && 
        _selectedDistrict == null && 
        _selectedLocality == null) {
      _filteredRoutes = _routes;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _filteredRoutes = await repository.filterRoutes(
        region: _selectedRegion,
        province: _selectedProvince,
        district: _selectedDistrict,
        locality: _selectedLocality,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void setRegion(String? region) {
    _selectedRegion = region;
    notifyListeners();
  }

  void setProvince(String? province) {
    _selectedProvince = province;
    notifyListeners();
  }

  void setDistrict(String? district) {
    _selectedDistrict = district;
    notifyListeners();
  }

  void setLocality(String? locality) {
    _selectedLocality = locality;
    notifyListeners();
  }

  void clearFilters() {
    _selectedRegion = null;
    _selectedProvince = null;
    _selectedDistrict = null;
    _selectedLocality = null;
    _filteredRoutes = _routes;
    notifyListeners();
  }

  Future<TransportRoute?> getRouteById(String id) async {
    try {
      return await repository.getRouteById(id);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }
}