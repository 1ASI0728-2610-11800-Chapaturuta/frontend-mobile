import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/map_with_markers.dart';
import '../../data/models/company_route_model.dart';
import '../providers/company_route_provider.dart';

class CompanyRouteMapScreen extends StatefulWidget {
  final CompanyRouteModel route;

  const CompanyRouteMapScreen({
    super.key,
    required this.route,
  });

  @override
  State<CompanyRouteMapScreen> createState() => _CompanyRouteMapScreenState();
}

class _CompanyRouteMapScreenState extends State<CompanyRouteMapScreen> {
  late Future<List<LatLng>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<CompanyRouteProvider>().loadGeometry(widget.route);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompanyRouteProvider>();
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(title: Text(widget.route.name)),
      body: FutureBuilder<List<LatLng>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold500));
          }
          final points = snapshot.data ?? [];
          if (points.isEmpty) {
            return const Center(
              child: Text('No hay geometria disponible', style: TextStyle(color: AppColors.carbon400)),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: MapWithMarkers(
              tileUrl: provider.tileUrl,
              center: points.first,
              polyline: points,
            ),
          );
        },
      ),
    );
  }
}
