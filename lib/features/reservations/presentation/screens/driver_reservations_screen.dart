import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/reservation_model.dart';
import '../providers/reservation_provider.dart';

/// Read-only list of reservations for the driver. Two modes:
///  - [tripId] set  → reservations placed on that trip (from a trip card).
///  - otherwise      → all reservations across the driver's trips ([driverId]).
///
/// The backend returns raw `ReservationResource` here (no resolved names), so we
/// show the document number, seats, status and dates that the payload carries.
class DriverReservationsScreen extends StatefulWidget {
  final int? tripId;
  final int? driverId;
  final String? title;

  const DriverReservationsScreen({
    super.key,
    this.tripId,
    this.driverId,
    this.title,
  }) : assert(tripId != null || driverId != null,
            'Provide either tripId or driverId');

  @override
  State<DriverReservationsScreen> createState() => _DriverReservationsScreenState();
}

class _DriverReservationsScreenState extends State<DriverReservationsScreen> {
  final _dateFmt = DateFormat('dd/MM/yyyy HH:mm');
  List<ReservationModel> _reservations = [];
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
      final api = context.read<ReservationProvider>().apiService;
      final data = widget.tripId != null
          ? await api.getByTrip(widget.tripId!)
          : await api.getByDriver(widget.driverId!);
      if (!mounted) return;
      setState(() {
        _reservations = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(title: Text(widget.title ?? 'Reservas recibidas')),
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
      return _centeredScroll(_message(Icons.error_outline, _error!));
    }
    if (_reservations.isEmpty) {
      return _centeredScroll(_message(Icons.confirmation_num_outlined, 'Aún no hay reservas.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _reservations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _card(_reservations[i]),
    );
  }

  Widget _card(ReservationModel r) {
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
              const Icon(Icons.badge_outlined, size: 18, color: AppColors.gold500),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${r.documentType}: ${r.documentNumber}',
                    style: const TextStyle(
                        color: AppColors.carbon50, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
              _statusBadge(r.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _chip(Icons.event_seat_outlined, '${r.seats} asiento(s)'),
              const SizedBox(width: 8),
              _chip(Icons.directions_bus_outlined, 'Viaje #${r.fkIdTrip}'),
            ],
          ),
          const SizedBox(height: 8),
          Text('Reservada: ${_dateFmt.format(r.reservedAt)}',
              style: const TextStyle(color: AppColors.carbon400, fontSize: 12)),
          if (r.confirmedAt != null)
            Text('Confirmada: ${_dateFmt.format(r.confirmedAt!)}',
                style: const TextStyle(color: AppColors.carbon400, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    late Color color;
    switch (status) {
      case 'Confirmed':
        color = AppColors.success;
        break;
      case 'Cancelled':
      case 'Expired':
        color = AppColors.danger;
        break;
      case 'Completed':
        color = AppColors.info;
        break;
      case 'Refunded':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.gold500;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(_reservationLabel(status).toUpperCase(),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
    );
  }

  String _reservationLabel(String status) {
    switch (status) {
      case 'Confirmed':
        return 'Confirmada';
      case 'Cancelled':
        return 'Cancelada';
      case 'Completed':
        return 'Completada';
      case 'Refunded':
        return 'Reembolsada';
      case 'Expired':
        return 'Expirada';
      default:
        return 'Pendiente';
    }
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

  Widget _centeredScroll(Widget child) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        child,
      ],
    );
  }

  Widget _message(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 40, color: AppColors.carbon600),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.carbon400)),
        ),
      ],
    );
  }
}
