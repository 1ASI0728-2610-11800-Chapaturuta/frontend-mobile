import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../../ratings/presentation/screens/rating_screen.dart';
import '../../data/models/trip_history_model.dart';
import '../providers/trip_provider.dart';

/// Passenger trip history (GET /trips/user/{id}/history). Completed trips can be rated:
/// we resolve the trip's driver (GET /trips/{id}) and open the rating screen.
class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  final _dateFmt = DateFormat('dd/MM/yyyy HH:mm');
  List<TripHistoryModel> _trips = [];
  bool _loading = true;
  String? _error;
  int? _resolvingTripId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  int? get _userId {
    final raw = context.read<UserProvider>().currentUser?.id;
    return raw == null ? null : int.tryParse(raw);
  }

  Future<void> _load() async {
    final userId = _userId;
    if (userId == null) {
      setState(() {
        _loading = false;
        _error = 'Debes iniciar sesión';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await context.read<TripProvider>().apiService.getUserHistory(userId);
      if (!mounted) return;
      setState(() {
        _trips = data;
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

  Future<void> _rate(TripHistoryModel trip) async {
    final userId = _userId;
    if (userId == null) return;
    setState(() => _resolvingTripId = trip.id);
    try {
      // TripHistory doesn't carry the driver id; fetch the trip aggregate to get it.
      final full = await context.read<TripProvider>().apiService.getById(trip.id);
      if (!mounted) return;
      setState(() => _resolvingTripId = null);
      if (full?.fkIdDriver == null) {
        _snack('Este viaje no tiene conductor asignado', isError: true);
        return;
      }
      final rated = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => RatingScreen(
            userId: userId,
            driverId: full!.fkIdDriver!,
            tripId: trip.id,
            driverName: trip.driverName,
          ),
        ),
      );
      if (rated == true && mounted) _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _resolvingTripId = null);
      _snack(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(title: const Text('Historial de viajes'), backgroundColor: AppColors.carbon950),
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
    if (_trips.isEmpty) {
      return _centered(Icons.directions_bus_outlined, 'Aún no tienes viajes.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _trips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _tripCard(_trips[i]),
    );
  }

  Widget _tripCard(TripHistoryModel trip) {
    final isCompleted = trip.statusKey == 'completed';
    final resolving = _resolvingTripId == trip.id;
    return Container(
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
              const Icon(Icons.person_outline, size: 14, color: AppColors.carbon400),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  trip.driverName.isNotEmpty ? trip.driverName : 'Conductor por asignar',
                  style: const TextStyle(color: AppColors.carbon200, fontSize: 12),
                ),
              ),
              Text(_dateFmt.format(trip.startTime),
                  style: const TextStyle(color: AppColors.carbon400, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('S/ ${trip.price?.toStringAsFixed(2) ?? '—'}',
                  style: const TextStyle(color: AppColors.gold500, fontWeight: FontWeight.w800)),
              const Spacer(),
              if (isCompleted)
                OutlinedButton.icon(
                  onPressed: resolving ? null : () => _rate(trip),
                  icon: resolving
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold500))
                      : const Icon(Icons.star_rounded, size: 16),
                  label: const Text('Calificar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold500,
                    side: const BorderSide(color: AppColors.gold500),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                ),
            ],
          ),
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

  Widget _centered(IconData icon, String text) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Icon(icon, size: 40, color: AppColors.carbon600),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.carbon400)),
        ),
      ],
    );
  }

  void _snack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? AppColors.danger : AppColors.success),
    );
  }
}
