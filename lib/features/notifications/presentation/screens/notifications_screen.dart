import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class _NotificationItem {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  bool read;

  _NotificationItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // TODO: endpoint pendiente de implementación en backend (/api/notifications)
  final List<_NotificationItem> _items = [
    _NotificationItem(
      icon: Icons.directions_bus_rounded,
      title: 'Nueva ruta disponible',
      body: 'Se agregó una ruta en tu zona de interés.',
      time: 'Hace 5 min',
      read: false,
    ),
    _NotificationItem(
      icon: Icons.star_rounded,
      title: 'Califica tu viaje',
      body: 'Completaste un viaje. ¿Cómo fue la experiencia?',
      time: 'Hace 2 h',
      read: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unread = _items.where((n) => !n.read).length;

    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(
        title: Row(
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
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.carbon950,
                  ),
                ),
              ),
            ],
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => setState(() {
                for (final n in _items) { n.read = true; }
              }),
              child: const Text('Marcar leídas', style: TextStyle(color: AppColors.gold400, fontSize: 13)),
            ),
        ],
      ),
      body: _items.isEmpty
          ? _buildEmpty()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _buildTile(_items[i], i),
            ),
    );
  }

  Widget _buildTile(_NotificationItem item, int index) {
    return Dismissible(
      key: Key('notif_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
      ),
      onDismissed: (_) => setState(() => _items.removeAt(index)),
      child: GestureDetector(
        onTap: () => setState(() => item.read = true),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.read ? AppColors.carbon800 : AppColors.carbon800,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: item.read ? AppColors.carbon700 : AppColors.gold500.withValues(alpha:0.35),
              width: item.read ? 1 : 1.5,
            ),
            boxShadow: item.read
                ? []
                : [
                    BoxShadow(
                      color: AppColors.gold500.withValues(alpha:0.1),
                      blurRadius: 12,
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold500.withValues(alpha:item.read ? 0.08 : 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.read ? AppColors.carbon400 : AppColors.gold500, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              color: item.read ? AppColors.carbon200 : AppColors.carbon50,
                              fontWeight: item.read ? FontWeight.w500 : FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (!item.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.gold500,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(item.body, style: const TextStyle(color: AppColors.carbon400, fontSize: 12), maxLines: 2),
                    const SizedBox(height: 4),
                    Text(item.time, style: const TextStyle(color: AppColors.carbon600, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none_rounded, size: 56, color: AppColors.carbon600),
          const SizedBox(height: 12),
          const Text('Sin notificaciones', style: TextStyle(color: AppColors.carbon200, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Te avisaremos cuando haya novedades', style: TextStyle(color: AppColors.carbon400, fontSize: 13)),
        ],
      ),
    );
  }
}
