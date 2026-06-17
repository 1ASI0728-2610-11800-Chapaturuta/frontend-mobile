import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/map_with_markers.dart';
import '../providers/stop_provider.dart';

class StopsMapScreen extends StatelessWidget {
  const StopsMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StopProvider>(
      builder: (context, provider, _) {
        final validStops = provider.stops
            .where((stop) => stop.latitude != 0 && stop.longitude != 0)
            .toList();
        final center = validStops.isEmpty
            ? const LatLng(-18.0146, -70.2536)
            : LatLng(validStops.first.latitude, validStops.first.longitude);

        if (validStops.isEmpty) {
          return const Center(
            child: Text('No hay coordenadas para mostrar', style: TextStyle(color: AppColors.carbon400)),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: MapWithMarkers(
            tileUrl: provider.tileUrl,
            center: center,
            markers: validStops
                .map((stop) => MapMarkerData(
                      point: LatLng(stop.latitude, stop.longitude),
                      label: stop.name,
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
