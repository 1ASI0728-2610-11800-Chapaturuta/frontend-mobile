import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_theme.dart';

class MapView extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final String tileUrl;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final void Function(TapPosition tapPosition, LatLng point)? onTap;

  const MapView({
    super.key,
    required this.center,
    required this.tileUrl,
    this.zoom = 13,
    this.markers = const [],
    this.polylines = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: zoom,
          onTap: onTap,
        ),
        children: [
          TileLayer(
            urlTemplate: tileUrl,
            userAgentPackageName: 'com.example.chapaturuta_client',
          ),
          if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
          if (markers.isNotEmpty) MarkerLayer(markers: markers),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap',
                textStyle: const TextStyle(color: AppColors.carbon100, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
