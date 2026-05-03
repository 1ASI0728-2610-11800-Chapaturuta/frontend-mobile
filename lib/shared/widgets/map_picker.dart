import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_theme.dart';
import 'map_view.dart';

class MapPicker extends StatefulWidget {
  final String tileUrl;
  final LatLng? initialPoint;
  final ValueChanged<LatLng> onChanged;

  const MapPicker({
    super.key,
    required this.tileUrl,
    required this.onChanged,
    this.initialPoint,
  });

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  static const _lima = LatLng(-12.0464, -77.0428);
  late LatLng _point;

  @override
  void initState() {
    super.initState();
    _point = widget.initialPoint ?? _lima;
    widget.onChanged(_point);
  }

  Future<void> _useCurrentLocation() async {
    final messenger = ScaffoldMessenger.of(context);
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      messenger.showSnackBar(const SnackBar(content: Text('Permiso de ubicacion denegado')));
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    _setPoint(LatLng(position.latitude, position.longitude));
  }

  void _setPoint(LatLng point) {
    setState(() => _point = point);
    widget.onChanged(point);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapView(
          center: _point,
          tileUrl: widget.tileUrl,
          onTap: (_, point) => _setPoint(point),
          markers: [
            Marker(
              point: _point,
              width: 44,
              height: 44,
              child: const Icon(Icons.location_pin, color: AppColors.gold500, size: 42),
            ),
          ],
        ),
        Positioned(
          right: 12,
          top: 12,
          child: IconButton.filled(
            tooltip: 'Usar mi ubicacion',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.carbon950,
              foregroundColor: AppColors.gold500,
            ),
            onPressed: _useCurrentLocation,
            icon: const Icon(Icons.my_location_rounded),
          ),
        ),
      ],
    );
  }
}
