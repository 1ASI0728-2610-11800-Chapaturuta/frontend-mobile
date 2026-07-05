import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../driver/presentation/providers/driver_provider.dart';
import '../../../network/routes/data/models/company_route_model.dart';
import '../../../network/routes/presentation/providers/company_route_provider.dart';
import '../../../reservations/presentation/screens/driver_reservations_screen.dart';
import '../../data/models/trip_history_model.dart';
import '../providers/trip_provider.dart';

/// Driver trip management: publish a trip with seat capacity, claim available trips,
/// and start/complete/cancel your own. Mirrors the web DriverTripsPage flow.
class DriverTripsScreen extends StatefulWidget {
  const DriverTripsScreen({super.key});

  @override
  State<DriverTripsScreen> createState() => _DriverTripsScreenState();
}

class _DriverTripsScreenState extends State<DriverTripsScreen> {
  final _dateFmt = DateFormat('dd/MM/yyyy HH:mm');
  int? _publishRouteId;
  bool _publishing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  int? get _driverId => context.read<DriverProvider>().driver?.id;
  int? get _userId {
    final raw = context.read<AuthProvider>().currentUser?.id;
    return raw == null ? null : int.tryParse(raw);
  }

  int? get _vehicleCapacity => context.read<DriverProvider>().driver?.vehicleCapacity;

  Future<void> _load() async {
    final driverId = _driverId;
    if (driverId == null) return;
    await Future.wait([
      context.read<TripProvider>().loadForDriver(driverId),
      context.read<CompanyRouteProvider>().load(driverId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(title: const Text('Gestión de viajes')),
      body: RefreshIndicator(
        color: AppColors.gold500,
        onRefresh: _load,
        child: Consumer<TripProvider>(
          builder: (context, trips, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _buildPublishCard(),
                const SizedBox(height: 24),
                _sectionTitle(Icons.inbox_outlined, 'Viajes disponibles'),
                const SizedBox(height: 8),
                if (trips.loadingAvailable)
                  _loadingRows()
                else if (trips.available.isEmpty)
                  _emptyState(Icons.inbox_outlined, 'No hay viajes disponibles por ahora')
                else
                  ...trips.available.map((t) => _tripCard(t, isMine: false)),
                const SizedBox(height: 24),
                _sectionTitle(Icons.directions_car_outlined, 'Mis viajes'),
                const SizedBox(height: 8),
                if (trips.loadingMine)
                  _loadingRows()
                else if (trips.mine.isEmpty)
                  _emptyState(Icons.directions_car_outlined, 'Aún no has tomado viajes')
                else
                  ...trips.mine.map((t) => _tripCard(t, isMine: true)),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Publish ─────────────────────────────────────────────────────────────────

  Widget _buildPublishCard() {
    final routes = context.watch<CompanyRouteProvider>().routes;
    final capacity = _vehicleCapacity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.campaign_outlined, 'Publicar viaje'),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _publishRouteId,
            isExpanded: true,
            dropdownColor: AppColors.carbon800,
            decoration: const InputDecoration(labelText: 'Ruta'),
            hint: const Text('Selecciona una ruta…',
                style: TextStyle(color: AppColors.carbon400)),
            items: routes
                .map((r) => DropdownMenuItem<int>(
                      value: r.id,
                      child: Text(_routeLabel(r),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _publishRouteId = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 18, color: AppColors.gold500),
              const SizedBox(width: 6),
              Text(
                capacity != null ? '$capacity asientos (capacidad del vehículo)' : 'Sin capacidad registrada',
                style: const TextStyle(color: AppColors.carbon200, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Los asientos se toman de la capacidad de tu vehículo registrado.',
            style: TextStyle(color: AppColors.carbon400, fontSize: 12),
          ),
          if (routes.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('No tienes rutas. Crea una en "Rutas" primero.',
                  style: TextStyle(color: AppColors.warning, fontSize: 12)),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_publishing || _publishRouteId == null || capacity == null || capacity == 0)
                  ? null
                  : _publish,
              icon: _publishing
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.carbon950))
                  : const Icon(Icons.campaign_outlined, size: 18),
              label: Text(_publishing ? 'Publicando…' : 'Publicar'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _publish() async {
    final routes = context.read<CompanyRouteProvider>().routes;
    CompanyRouteModel? route;
    for (final r in routes) {
      if (r.id == _publishRouteId) {
        route = r;
        break;
      }
    }
    final driverId = _driverId;
    final userId = _userId;
    final capacity = _vehicleCapacity;

    if (route == null || driverId == null || userId == null || capacity == null) return;
    if (route.stopIds.length < 2) {
      _snack('La ruta necesita origen y destino.', isError: true);
      return;
    }

    setState(() => _publishing = true);
    final ok = await context.read<TripProvider>().publish(
          fkIdUser: userId,
          fkIdDriver: driverId,
          fkIdRoute: route.id,
          fkIdOriginStop: route.stopIds.first,
          fkIdDestinationStop: route.stopIds.last,
          price: route.price,
          seats: capacity,
        );
    if (!mounted) return;
    setState(() {
      _publishing = false;
      if (ok) _publishRouteId = null;
    });
    _snack(
      ok ? 'Viaje publicado · $capacity asientos' : (context.read<TripProvider>().error ?? 'No se pudo publicar'),
      isError: !ok,
    );
  }

  String _routeLabel(CompanyRouteModel r) {
    final base = r.name.isNotEmpty ? r.name : 'Ruta #${r.id}';
    return '$base · S/ ${r.price.toStringAsFixed(2)}';
  }

  // ── Trip card ───────────────────────────────────────────────────────────────

  Widget _tripCard(TripHistoryModel trip, {required bool isMine}) {
    final acting = context.watch<TripProvider>().actingTripId == trip.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(trip.routeName,
                    style: const TextStyle(
                        color: AppColors.carbon50, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              _statusBadge(trip.status),
            ],
          ),
          const SizedBox(height: 4),
          Text('${trip.originName} → ${trip.destinationName}',
              style: const TextStyle(color: AppColors.carbon400, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              _chip(Icons.people_outline, '${trip.availableSeats} asientos'),
              const SizedBox(width: 8),
              _chip(Icons.schedule, _dateFmt.format(trip.startTime)),
              const Spacer(),
              Text('S/ ${trip.price?.toStringAsFixed(2) ?? '—'}',
                  style: const TextStyle(color: AppColors.gold500, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          _tripActions(trip, isMine: isMine, acting: acting),
        ],
      ),
    );
  }

  Widget _tripActions(TripHistoryModel trip, {required bool isMine, required bool acting}) {
    final driverId = _driverId;
    if (driverId == null) return const SizedBox.shrink();

    if (!isMine) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: acting ? null : () => _run(() => context.read<TripProvider>().take(trip.id, driverId)),
          icon: const Icon(Icons.check_box_outlined, size: 18),
          label: Text(acting ? 'Tomando…' : 'Tomar viaje'),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (trip.canStart)
          _actionButton('Iniciar', Icons.play_arrow_rounded, AppColors.gold500, AppColors.carbon950,
              acting ? null : () => _run(() => context.read<TripProvider>().start(trip.id, driverId))),
        if (trip.canComplete)
          _actionButton('Completar', Icons.check_rounded, AppColors.success, AppColors.carbon950,
              acting ? null : () => _run(() => context.read<TripProvider>().complete(trip.id, driverId))),
        if (trip.canCancel)
          _actionButton('Cancelar', Icons.close_rounded, AppColors.danger, Colors.white,
              acting ? null : () => _confirmCancel(trip, driverId)),
        _actionButton('Reservas', Icons.confirmation_num_outlined, AppColors.carbon700, AppColors.carbon100,
            () => _openReservations(trip)),
      ],
    );
  }

  Future<void> _confirmCancel(TripHistoryModel trip, int driverId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.carbon800,
        title: const Text('Cancelar viaje', style: TextStyle(color: AppColors.carbon50)),
        content: Text('¿Seguro que deseas cancelar "${trip.routeName}"?',
            style: const TextStyle(color: AppColors.carbon200)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, cancelar', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _run(() => context.read<TripProvider>().cancel(trip.id, driverId));
    }
  }

  void _openReservations(TripHistoryModel trip) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DriverReservationsScreen(tripId: trip.id, title: trip.routeName),
      ),
    );
  }

  Future<void> _run(Future<bool> Function() action) async {
    final ok = await action();
    if (!mounted) return;
    if (!ok) _snack(context.read<TripProvider>().error ?? 'No se pudo actualizar el viaje', isError: true);
  }

  // ── Small UI helpers ─────────────────────────────────────────────────────────

  Widget _sectionTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gold500, size: 20),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                color: AppColors.carbon100, fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon, Color bg, Color fg, VoidCallback? onTap) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        icon: Icon(icon, size: 16),
        label: Text(label),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.carbon900,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.carbon400),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: AppColors.carbon200, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final key = status.toLowerCase().replaceAll(RegExp(r'[\s_]'), '');
    late Color color;
    late String label;
    switch (key) {
      case 'inprogress':
        color = AppColors.info;
        label = 'En curso';
        break;
      case 'completed':
        color = AppColors.success;
        label = 'Completado';
        break;
      case 'cancelled':
      case 'canceled':
        color = AppColors.danger;
        label = 'Cancelado';
        break;
      default:
        color = AppColors.gold500;
        label = 'Pendiente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label.toUpperCase(),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
    );
  }

  Widget _loadingRows() {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          height: 96,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.carbon800,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, size: 34, color: AppColors.carbon600),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: AppColors.carbon400)),
        ],
      ),
    );
  }

  void _snack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.carbon50,
      ),
    );
  }
}
