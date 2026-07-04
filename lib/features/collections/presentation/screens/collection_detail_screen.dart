import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../routes/domain/entities/route.dart';
import '../../../routes/presentation/providers/route_provider.dart';
import '../../../routes/presentation/screens/route_detail_screen.dart';
import '../../data/models/collection_model.dart';
import '../providers/collection_provider.dart';

/// Shows the routes saved in a collection. Each item stores only `fkIdRoute`, so we
/// resolve the full route via RouteProvider to render name/price and allow opening it.
class CollectionDetailScreen extends StatefulWidget {
  final CollectionModel collection;

  const CollectionDetailScreen({super.key, required this.collection});

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  List<_ResolvedItem> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<CollectionProvider>().apiService;
      final routeProvider = context.read<RouteProvider>();
      final items = await api.getRoutes(widget.collection.id);
      final resolved = <_ResolvedItem>[];
      for (final item in items) {
        final route = await routeProvider.getRouteById(item.fkIdRoute.toString());
        resolved.add(_ResolvedItem(routeId: item.fkIdRoute, route: route));
      }
      if (!mounted) return;
      setState(() {
        _items = resolved;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _remove(int routeId) async {
    final ok = await context.read<CollectionProvider>().removeRoute(widget.collection.id, routeId);
    if (!mounted) return;
    if (ok) {
      setState(() => _items.removeWhere((i) => i.routeId == routeId));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo quitar la ruta'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(title: Text(widget.collection.name), backgroundColor: AppColors.carbon950),
      body: RefreshIndicator(
        color: AppColors.gold500,
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.gold500));
    }
    if (_error != null) {
      return _centered(Icons.error_outline, _error!);
    }
    if (_items.isEmpty) {
      return _centered(Icons.directions_bus_outlined,
          'Colección vacía.\nAgrega rutas desde el detalle de cada ruta.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _itemCard(_items[i]),
    );
  }

  Widget _itemCard(_ResolvedItem item) {
    final route = item.route;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.gold500.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.directions_bus_rounded, color: AppColors.gold500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(route?.name ?? 'Ruta #${item.routeId}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.carbon50, fontWeight: FontWeight.w700, fontSize: 14)),
                if (route != null)
                  Text('S/ ${route.price.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.gold500, fontSize: 12)),
              ],
            ),
          ),
          if (route != null)
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded, color: AppColors.carbon400, size: 20),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RouteDetailScreen(routeId: item.routeId.toString())),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
            onPressed: () => _remove(item.routeId),
          ),
        ],
      ),
    );
  }

  Widget _centered(IconData icon, String text) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Icon(icon, size: 44, color: AppColors.carbon600),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.carbon400)),
        ),
      ],
    );
  }
}

class _ResolvedItem {
  final int routeId;
  final TransportRoute? route;
  const _ResolvedItem({required this.routeId, this.route});
}
