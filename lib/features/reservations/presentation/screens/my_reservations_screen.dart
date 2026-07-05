import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../data/models/reservation_model.dart';
import '../providers/reservation_provider.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = context.read<UserProvider>().currentUser;
    if (user == null) return;
    final userId = int.tryParse(user.id) ?? 0;
    await context.read<ReservationProvider>().loadByUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(
        title: const Text('Mis reservas'),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.carbon950,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold500,
          labelColor: AppColors.gold500,
          unselectedLabelColor: AppColors.carbon400,
          tabs: const [
            Tab(text: 'Activas'),
            Tab(text: 'Completadas'),
            Tab(text: 'Canceladas'),
          ],
        ),
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.reservations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold500),
            );
          }
          if (provider.error != null && provider.reservations.isEmpty) {
            return _EmptyState(
              icon: Icons.wifi_off_rounded,
              message: provider.error!,
              onRetry: _load,
            );
          }

          final active = provider.reservations
              .where((r) => r.status == 'Pending' || r.status == 'Confirmed')
              .toList();
          final completed = provider.reservations
              .where((r) => r.status == 'Completed')
              .toList();
          final cancelled = provider.reservations
              .where((r) => r.status == 'Cancelled' || r.status == 'Refunded')
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(active, 'Sin reservas activas', Icons.confirmation_num_outlined),
              _buildList(completed, 'Sin viajes completados', Icons.check_circle_outline_rounded),
              _buildList(cancelled, 'Sin cancelaciones', Icons.cancel_outlined),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<ReservationModel> items, String emptyMsg, IconData emptyIcon) {
    if (items.isEmpty) {
      return _EmptyState(icon: emptyIcon, message: emptyMsg, onRetry: _load);
    }
    return RefreshIndicator(
      color: AppColors.gold500,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _ReservationCard(
          reservation: items[index],
          onCancel: () => _cancelReservation(items[index]),
          onConfirm: () => _confirmReservation(items[index]),
        ),
      ),
    );
  }

  Future<void> _cancelReservation(ReservationModel reservation) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.carbon800,
        title: const Text('Cancelar reserva', style: TextStyle(color: AppColors.carbon50)),
        content: const Text(
          'Se cancelara tu reserva y se liberaran los asientos. Esta accion no se puede deshacer.',
          style: TextStyle(color: AppColors.carbon400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Volver', style: TextStyle(color: AppColors.carbon400)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancelar reserva'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;
    final provider = context.read<ReservationProvider>();
    final success = await provider.cancel(reservation.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Reserva cancelada' : provider.error ?? 'Error'),
        backgroundColor: success ? AppColors.success : AppColors.danger,
      ),
    );
  }

  Future<void> _confirmReservation(ReservationModel reservation) async {
    final provider = context.read<ReservationProvider>();
    final success = await provider.confirm(reservation.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Reserva confirmada' : provider.error ?? 'Error'),
        backgroundColor: success ? AppColors.success : AppColors.danger,
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _ReservationCard({
    required this.reservation,
    required this.onCancel,
    required this.onConfirm,
  });

  Color _statusColor() {
    switch (reservation.status) {
      case 'Confirmed':
        return AppColors.success;
      case 'Cancelled':
      case 'Refunded':
        return AppColors.danger;
      case 'Completed':
        return AppColors.info;
      default:
        return AppColors.gold500;
    }
  }

  IconData _statusIcon() {
    switch (reservation.status) {
      case 'Confirmed':
        return Icons.check_circle_rounded;
      case 'Cancelled':
      case 'Refunded':
        return Icons.cancel_rounded;
      case 'Completed':
        return Icons.task_alt_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    final date = reservation.reservedAt;
    final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_statusIcon(), color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reserva #${reservation.id}',
                      style: const TextStyle(
                        color: AppColors.carbon50,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$dateStr a las $timeStr',
                      style: const TextStyle(color: AppColors.carbon400, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  reservation.statusLabel,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.carbon900.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _infoChip(Icons.event_seat_rounded, '${reservation.seats} asiento${reservation.seats > 1 ? 's' : ''}'),
                const SizedBox(width: 12),
                _infoChip(Icons.badge_rounded, reservation.documentNumber),
                const Spacer(),
                if (reservation.price != null)
                  Text(
                    'S/ ${(reservation.price! * reservation.seats).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.gold500,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
              ],
            ),
          ),
          if (reservation.canCancel || reservation.canConfirm) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (reservation.canConfirm)
                  TextButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Confirmar'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.success),
                  ),
                if (reservation.canCancel)
                  TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Cancelar'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.carbon400, size: 14),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: AppColors.carbon400, fontSize: 12)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Future<void> Function() onRetry;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.carbon600, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.carbon400, fontSize: 14),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Actualizar'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.gold500),
            ),
          ],
        ),
      ),
    );
  }
}
