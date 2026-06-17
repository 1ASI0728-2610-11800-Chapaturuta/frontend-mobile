import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/map_with_markers.dart';
import '../../../../driver/presentation/providers/driver_provider.dart';
import '../../../../network/stops/data/models/company_stop_model.dart';
import '../../../../network/stops/presentation/providers/stop_provider.dart';
import '../../data/models/company_route_model.dart';
import '../providers/company_route_provider.dart';

const _kDayKeys = ['Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'];

class CompanyRouteFormScreen extends StatefulWidget {
  final CompanyRouteModel? route;

  const CompanyRouteFormScreen({super.key, this.route});

  @override
  State<CompanyRouteFormScreen> createState() => _CompanyRouteFormScreenState();
}

class _CompanyRouteFormScreenState extends State<CompanyRouteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _frequencyCtrl = TextEditingController();
  final List<int> _selectedStopIds = [];
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

  void _toggleStop(int stopId) {
    setState(() {
      if (_selectedStopIds.contains(stopId)) {
        _selectedStopIds.remove(stopId);
      } else {
        _selectedStopIds.add(stopId);
      }
    });
  }

  void _reorderStops(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _selectedStopIds.removeAt(oldIndex);
      _selectedStopIds.insert(newIndex, item);
    });
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
        const SnackBar(content: Text('Activa al menos un dia de servicio')),
      );
      return;
    }

    final provider = context.read<CompanyRouteProvider>();
    final ok = await provider.save(
      CompanyRouteModel(
        id: widget.route?.id ?? 0,
        companyId: 0,
        name: '',
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

    final selectedStops = <CompanyStopModel>[];
    for (final id in _selectedStopIds) {
      final match = stops.where((s) => s.id == id);
      if (match.isNotEmpty) selectedStops.add(match.first);
    }

    final previewStops = selectedStops
        .where((s) => s.latitude != 0 && s.longitude != 0)
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
              _field(_priceCtrl, 'Precio (S/.)',
                  keyboardType: TextInputType.number,
                  validator: (v) => _required(v, 'Precio')),
              const SizedBox(height: 14),
              _field(_durationCtrl, 'Duracion estimada (minutos)',
                  keyboardType: TextInputType.number,
                  validator: (v) => _required(v, 'Duracion')),
              const SizedBox(height: 14),
              _field(_frequencyCtrl, 'Frecuencia de salida (minutos)',
                  keyboardType: TextInputType.number,
                  validator: (v) => _required(v, 'Frecuencia')),
              const SizedBox(height: 20),

              // --- Stop selection ---
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Paraderos',
                      style: TextStyle(color: AppColors.carbon50, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                  Text(
                    '${_selectedStopIds.length} seleccionados',
                    style: const TextStyle(color: AppColors.carbon400, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Selecciona paraderos en el orden de la ruta (origen a destino)',
                style: TextStyle(color: AppColors.carbon600, fontSize: 12),
              ),
              const SizedBox(height: 10),

              if (stops.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.carbon800,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.carbon700),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.pin_drop_outlined, color: AppColors.carbon600, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Crea paraderos antes de crear rutas',
                        style: TextStyle(color: AppColors.carbon400),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else ...[
                // Available stops to add
                ...stops.where((s) => !_selectedStopIds.contains(s.id)).map(
                  (stop) => _StopSelectTile(
                    stop: stop,
                    selected: false,
                    order: null,
                    onTap: () => _toggleStop(stop.id),
                  ),
                ),

                if (_selectedStopIds.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Orden de la ruta (arrastra para reordenar)',
                    style: TextStyle(color: AppColors.gold400, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedStops.length,
                    // ignore: deprecated_member_use
                    onReorder: _reorderStops,
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        color: Colors.transparent,
                        elevation: 4,
                        shadowColor: AppColors.gold500.withValues(alpha: 0.3),
                        child: child,
                      );
                    },
                    itemBuilder: (context, index) {
                      final stop = selectedStops[index];
                      final isFirst = index == 0;
                      final isLast = index == selectedStops.length - 1;
                      return _StopOrderTile(
                        key: ValueKey(stop.id),
                        stop: stop,
                        order: index + 1,
                        isFirst: isFirst,
                        isLast: isLast,
                        onRemove: () => _toggleStop(stop.id),
                      );
                    },
                  ),
                ],
              ],

              const SizedBox(height: 20),
              const Text(
                'Horarios de operacion',
                style: TextStyle(color: AppColors.carbon50, fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ..._kDayKeys.map(_scheduleRow),

              if (previewStops.length >= 2) ...[
                const SizedBox(height: 18),
                const Text(
                  'Vista previa del recorrido',
                  style: TextStyle(color: AppColors.carbon50, fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 240,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: MapWithMarkers(
                      tileUrl: stopProvider.tileUrl,
                      center: previewStops.first.latitude != 0
                          ? LatLng(previewStops.first.latitude, previewStops.first.longitude)
                          : const LatLng(-18.0146, -70.2536),
                      markers: previewStops
                          .asMap()
                          .entries
                          .map((e) => MapMarkerData(
                                point: LatLng(e.value.latitude, e.value.longitude),
                                label: '${e.key + 1}. ${e.value.name}',
                              ))
                          .toList(),
                      polyline: previewStops
                          .map((s) => LatLng(s.latitude, s.longitude))
                          .toList(),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: routeProvider.isLoading ? null : _save,
                  icon: routeProvider.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.carbon950),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(widget.route == null ? 'Crear ruta' : 'Guardar cambios'),
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

class _StopSelectTile extends StatelessWidget {
  final CompanyStopModel stop;
  final bool selected;
  final int? order;
  final VoidCallback onTap;

  const _StopSelectTile({
    required this.stop,
    required this.selected,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: ListTile(
        dense: true,
        onTap: onTap,
        leading: const Icon(Icons.add_circle_outline, color: AppColors.gold500, size: 22),
        title: Text(stop.name, style: const TextStyle(color: AppColors.carbon50, fontSize: 14)),
        subtitle: Text(stop.address, style: const TextStyle(color: AppColors.carbon400, fontSize: 11)),
      ),
    );
  }
}

class _StopOrderTile extends StatelessWidget {
  final CompanyStopModel stop;
  final int order;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onRemove;

  const _StopOrderTile({
    super.key,
    required this.stop,
    required this.order,
    required this.isFirst,
    required this.isLast,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final label = isFirst
        ? 'Origen'
        : isLast
            ? 'Destino'
            : 'Parada $order';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isFirst || isLast) ? AppColors.gold500.withValues(alpha: 0.5) : AppColors.carbon700,
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: (isFirst || isLast) ? AppColors.gold500 : AppColors.carbon700,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$order',
              style: TextStyle(
                color: (isFirst || isLast) ? AppColors.carbon950 : AppColors.carbon50,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
        title: Text(stop.name, style: const TextStyle(color: AppColors.carbon50, fontSize: 14)),
        subtitle: Text(label, style: TextStyle(
          color: (isFirst || isLast) ? AppColors.gold400 : AppColors.carbon400,
          fontSize: 11,
          fontWeight: (isFirst || isLast) ? FontWeight.w600 : FontWeight.w400,
        )),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger, size: 20),
              onPressed: onRemove,
              tooltip: 'Quitar',
            ),
            const Icon(Icons.drag_handle_rounded, color: AppColors.carbon600, size: 20),
          ],
        ),
      ),
    );
  }
}
