import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_provider.dart';

/// User notifications backed by /api/notifications: load, mark-as-read (tap) and
/// delete (swipe).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
    if (userId == null) return;
    await context.read<NotificationProvider>().load(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            final unread = provider.unreadCount;
            return Row(
              children: [
                const Text('Alertas'),
                if (unread > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gold500,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$unread',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.carbon950)),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => provider.markAllAsRead(),
                child: const Text('Marcar leídas', style: TextStyle(color: AppColors.gold400, fontSize: 13)),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold500));
          }
          if (provider.notifications.isEmpty) {
            return _empty(provider.error);
          }
          return RefreshIndicator(
            color: AppColors.gold500,
            onRefresh: _load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _tile(provider, provider.notifications[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _tile(NotificationProvider provider, NotificationModel item) {
    return Dismissible(
      key: ValueKey('notif_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
      ),
      onDismissed: (_) => provider.delete(item.id),
      child: GestureDetector(
        onTap: () => provider.markAsRead(item.id),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.carbon800,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: item.isRead ? AppColors.carbon700 : AppColors.gold500.withValues(alpha: 0.35),
              width: item.isRead ? 1 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold500.withValues(alpha: item.isRead ? 0.08 : 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconFor(item.type),
                    color: item.isRead ? AppColors.carbon400 : AppColors.gold500, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.title,
                              style: TextStyle(
                                color: item.isRead ? AppColors.carbon200 : AppColors.carbon50,
                                fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                                fontSize: 13,
                              )),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(color: AppColors.gold500, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(item.message,
                        style: const TextStyle(color: AppColors.carbon400, fontSize: 12), maxLines: 3),
                    const SizedBox(height: 4),
                    Text(_relativeTime(item.createdAt),
                        style: const TextStyle(color: AppColors.carbon600, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return Icons.check_circle_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'error':
        return Icons.error_rounded;
      case 'trip':
        return Icons.directions_bus_rounded;
      case 'payment':
        return Icons.payments_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 30) return 'Hace ${diff.inDays} d';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _empty(String? error) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.28),
        Icon(error != null ? Icons.wifi_off_rounded : Icons.notifications_none_rounded,
            size: 56, color: AppColors.carbon600),
        const SizedBox(height: 12),
        Text(error ?? 'Sin notificaciones',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.carbon200, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const Text('Te avisaremos cuando haya novedades',
            textAlign: TextAlign.center, style: TextStyle(color: AppColors.carbon400, fontSize: 13)),
      ],
    );
  }
}
