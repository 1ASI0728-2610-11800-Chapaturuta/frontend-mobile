import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_theme.dart';
import 'map_view.dart';

class MapMarkerData {
  final LatLng point;
  final String label;

  const MapMarkerData({
    required this.point,
    required this.label,
  });
}

class MapWithMarkers extends StatelessWidget {
  final String tileUrl;
  final LatLng center;
  final List<MapMarkerData> markers;
  final List<LatLng> polyline;

  const MapWithMarkers({
    super.key,
    required this.tileUrl,
    required this.center,
    this.markers = const [],
    this.polyline = const [],
  });

  @override
  Widget build(BuildContext context) {
    return MapView(
      tileUrl: tileUrl,
      center: center,
      markers: markers
          .map(
            (item) => Marker(
              point: item.point,
              width: 44,
              height: 44,
              child: Tooltip(
                message: item.label,
                child: const Icon(Icons.location_pin, color: AppColors.gold500, size: 38),
              ),
            ),
          )
          .toList(),
      polylines: [
        if (polyline.isNotEmpty)
          Polyline(
            points: polyline,
            color: AppColors.gold500,
            strokeWidth: 4,
          ),
      ],
    );
  }
}
