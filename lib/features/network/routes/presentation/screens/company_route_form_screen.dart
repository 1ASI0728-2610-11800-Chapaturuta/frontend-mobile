import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/map_with_markers.dart';
import '../../../../driver/presentation/providers/driver_provider.dart';
import '../../../../network/stops/presentation/providers/stop_provider.dart';
import '../../data/models/company_route_model.dart';
import '../providers/company_route_provider.dart';

const _kDayKeys = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

class CompanyRouteFormScreen extends StatefulWidget {
  final CompanyRouteModel? route;

  const CompanyRouteFormScreen({super.key, this.route});

  @override
  State<CompanyRouteFormScreen> createState() => _CompanyRouteFormScreenState();
}

class _CompanyRouteFormScreenState extends State<CompanyRouteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _frequencyCtrl = TextEditingController();
  final Set<int> _selectedStopIds = {};
  late Map<String, RouteScheduleModel> _schedules;

  @override
  void initState() {
    super.initState();
    _schedules = {
      for (final day in _kDayKeys)
        day: RouteScheduleModel(dayOfWeek: day, enabled: day != 'Domingo'),
    };
    final route = widget.route;
    if (route != null) {
      _nameCtrl.text = route.name;
      _priceCtrl.text = route.price.toStringAsFixed(2);
      _durationCtrl.text = route.duration.toString();
      _frequencyCtrl.text = route.frequency.toString();
      _selectedStopIds.addAll(route.stopIds);
      for (final schedule in route.schedules) {
        _schedules[schedule.dayOfWeek] = schedule;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final driver = context.read<DriverProvider>().driver;
      if (driver != null) context.read<StopProvider>().load(driver.id);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _frequencyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(String day, bool isStart) async {
    final current = _schedules[day]!;
    final initial = _parseTime(isStart ? current.startTime : current.endTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.gold500,
            onPrimary: AppColors.carbon950,
            surface: AppColors.carbon800,
            onSurface: AppColors.carbon50,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final formatted = _formatTime(picked);
    setState(() {
      _schedules[day] = current.copyWith(
        startTime: isStart ? formatted : current.startTime,
        endTime: isStart ? current.endTime : formatted,
      );
    });
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return const TimeOfDay(hour: 6, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 6,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _formatTime(TimeOfDay t) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(t.hour)}:${pad(t.minute)}';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStopIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos dos paraderos')),
      );
      return;
    }
    final activeSchedules = _schedules.values.where((s) => s.enabled).toList();
    if (activeSchedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activa al menos un día de servicio')),
      );
      return;
    }

    final driver = context.read<DriverProvider>().driver;
    if (driver == null) return;
    final provider = context.read<CompanyRouteProvider>();
    final ok = await provider.save(
      CompanyRouteModel(
        id: widget.route?.id ?? 0,
        companyId: driver.id,
        name: _nameCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
        duration: int.tryParse(_durationCtrl.text.trim()) ?? 0,
        frequency: int.tryParse(_frequencyCtrl.text.trim()) ?? 0,
        stopIds: _selectedStopIds.toList(),
        schedules: activeSchedules,
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Ruta guardada' : provider.error ?? 'No se pudo guardar')),
    );
    if (ok) Navigator.of(context).pop();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label es obligatorio';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final stops = context.watch<StopProvider>().stops;
    final stopProvider = context.watch<StopProvider>();
    final routeProvider = context.watch<CompanyRouteProvider>();
    final previewStops = stops
        .where((stop) => _selectedStopIds.contains(stop.id) && stop.latitude != 0 && stop.longitude != 0)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(title: Text(widget.route == null ? 'Nueva ruta' : 'Editar ruta')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _field(_nameCtrl, 'Nombre', validator: (v) => _required(v, 'Nombre')),
              const SizedBox(height: 14),
              _field(_priceCtrl, 'Precio', keyboardType: TextInputType.number, validator: (v) => _required(v, 'Precio')),
              const SizedBox(height: 14),
              _field(_durationCtrl, 'Duracion en minutos', keyboardType: TextInputType.number),
              const SizedBox(height: 14),
              _field(_frequencyCtrl, 'Frecuencia en minutos', keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              const Text(
                'Paraderos',
                style: TextStyle(color: AppColors.carbon50, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (stops.isEmpty)
                const Text('Crea paraderos antes de crear rutas', style: TextStyle(color: AppColors.carbon400))
              else
                ...stops.map(
                  (stop) => CheckboxListTile(
                    value: _selectedStopIds.contains(stop.id),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedStopIds.add(stop.id);
                        } else {
                          _selectedStopIds.remove(stop.id);
                        }
                      });
                    },
                    activeColor: AppColors.gold500,
                    checkColor: AppColors.carbon950,
                    title: Text(stop.name, style: const TextStyle(color: AppColors.carbon50)),
                    subtitle: Text(stop.address, style: const TextStyle(color: AppColors.carbon400)),
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                'Horarios',
                style: TextStyle(color: AppColors.carbon50, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ..._kDayKeys.map(_scheduleRow),
              if (previewStops.length >= 2) ...[
                const SizedBox(height: 18),
                SizedBox(
                  height: 240,
                  child: MapWithMarkers(
                    tileUrl: stopProvider.tileUrl,
                    center: LatLng(previewStops.first.latitude, previewStops.first.longitude),
                    markers: previewStops
                        .map((stop) => MapMarkerData(
                              point: LatLng(stop.latitude, stop.longitude),
                              label: stop.name,
                            ))
                        .toList(),
                    polyline: previewStops
                        .map((stop) => LatLng(stop.latitude, stop.longitude))
                        .toList(),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: routeProvider.isLoading ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar ruta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scheduleRow(String day) {
    final schedule = _schedules[day]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: Row(
        children: [
          Switch(
            value: schedule.enabled,
            onChanged: (value) => setState(
              () => _schedules[day] = schedule.copyWith(enabled: value),
            ),
            activeThumbColor: AppColors.gold500,
          ),
          SizedBox(
            width: 92,
            child: Text(day, style: const TextStyle(color: AppColors.carbon50)),
          ),
          const Spacer(),
          _timeChip(day, isStart: true, label: schedule.startTime),
          const SizedBox(width: 6),
          const Text('-', style: TextStyle(color: AppColors.carbon400)),
          const SizedBox(width: 6),
          _timeChip(day, isStart: false, label: schedule.endTime),
        ],
      ),
    );
  }

  Widget _timeChip(String day, {required bool isStart, required String label}) {
    return InkWell(
      onTap: () => _pickTime(day, isStart),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.carbon700,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: const TextStyle(color: AppColors.carbon50, fontSize: 12)),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.carbon50),
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}
