import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/route.dart';
import '../providers/route_provider.dart';

class RouteDetailScreen extends StatefulWidget {
  final String routeId;

  const RouteDetailScreen({super.key, required this.routeId});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  TransportRoute? route;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    final loaded = await context.read<RouteProvider>().getRouteById(widget.routeId);
    setState(() {
      route = loaded;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.carbon900,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold500)),
      );
    }
    if (route == null) {
      return Scaffold(
        backgroundColor: AppColors.carbon900,
        appBar: AppBar(title: const Text('Ruta')),
        body: const Center(
          child: Text('Ruta no encontrada', style: TextStyle(color: AppColors.carbon400)),
        ),
      );
    }

    final isFavorite = context.select<RouteProvider, bool>(
      (p) => p.isFavorite(route!.id),
    );
    final isActive = route!.state == 'Active';

    return Scaffold(
      backgroundColor: AppColors.carbon900,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.carbon950,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.carbon800.withValues(alpha:0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.carbon700),
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.carbon100, size: 20),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  context.read<RouteProvider>().toggleFavorite(route!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isFavorite ? 'Eliminado de favoritos' : 'Guardado en favoritos'),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.carbon800.withValues(alpha:0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isFavorite ? AppColors.gold500 : AppColors.carbon700,
                    ),
                  ),
                  child: Icon(
                    isFavorite ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: isFavorite ? AppColors.gold500 : AppColors.carbon200,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'route-${route!.id}',
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.carbon700, AppColors.carbon800, AppColors.carbon900],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.directions_bus_rounded,
                      size: 80,
                      color: AppColors.gold500.withValues(alpha:0.35),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              route!.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.carbon50,
                                letterSpacing: -0.44,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.success.withValues(alpha:0.15)
                                    : AppColors.danger.withValues(alpha:0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isActive ? 'Activo' : 'Inactivo',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? AppColors.success : AppColors.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'S/ ${route!.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.carbon800,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.carbon700),
                    ),
                    child: Row(
                      children: [
                        _buildStatItem(Icons.access_time_rounded, 'Duración', route!.duration),
                        Container(height: 40, width: 1, color: AppColors.carbon700),
                        _buildStatItem(Icons.straighten_rounded, 'Distancia', route!.distance),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (route!.originAddress != null || route!.destinationAddress != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.carbon800,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.carbon700),
                      ),
                      child: Column(
                        children: [
                          if (route!.originAddress != null)
                            _buildAddressRow(
                              Icons.radio_button_checked,
                              AppColors.success,
                              'Origen',
                              route!.originAddress!,
                            ),
                          if (route!.originAddress != null && route!.destinationAddress != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Container(
                                width: 1,
                                height: 20,
                                color: AppColors.carbon700,
                              ),
                            ),
                          if (route!.destinationAddress != null)
                            _buildAddressRow(
                              Icons.location_on_rounded,
                              AppColors.gold500,
                              'Destino',
                              route!.destinationAddress!,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gold600, AppColors.gold500, AppColors.gold400],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold500.withValues(alpha:0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: AppColors.carbon950,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.star_rounded, size: 20),
                        label: const Text('Calificar esta ruta', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.gold500, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.carbon400, fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.carbon100,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, Color iconColor, String label, String address) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.carbon400, fontSize: 11)),
              Text(address,
                  style: const TextStyle(color: AppColors.carbon100, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
