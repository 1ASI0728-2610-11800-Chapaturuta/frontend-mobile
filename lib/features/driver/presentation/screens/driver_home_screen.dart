import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/driver_provider.dart';

class DriverHomeScreen extends StatelessWidget {
  final VoidCallback? onOpenProfile;

  const DriverHomeScreen({super.key, this.onOpenProfile});

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverProvider>(
      builder: (context, provider, _) {
        final driver = provider.driver;
        return RefreshIndicator(
          color: AppColors.gold500,
          onRefresh: () => provider.loadForUser(driver?.fkIdUser.toString() ?? ''),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              Text(
                driver != null ? driver.fullName : 'Conductor',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.carbon50,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                driver != null ? '${driver.vehicleBrand} ${driver.vehicleModel}' : 'Panel de conductor',
                style: const TextStyle(color: AppColors.carbon400),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.badge_outlined,
                      label: 'Licencia',
                      value: driver?.licenseCategory ?? '-',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.directions_car_outlined,
                      label: 'Placa',
                      value: driver?.vehiclePlate ?? '-',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.people_outline,
                      label: 'Capacidad',
                      value: '${driver?.vehicleCapacity ?? 0} pax',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      icon: driver?.isAvailable == true
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      label: 'Disponibilidad',
                      value: driver?.isAvailable == true ? 'Activo' : 'Inactivo',
                      iconColor: driver?.isAvailable == true ? Colors.green : AppColors.danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _ActionTile(
                icon: Icons.route_rounded,
                title: 'Gestión de red',
                subtitle: 'Administra paraderos y rutas desde la barra inferior',
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.person_outline_rounded,
                title: 'Mi perfil',
                subtitle: 'Nombre, vehículo, licencia y disponibilidad',
                onTap: onOpenProfile,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? AppColors.gold500, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.carbon50,
                      fontSize: 16,
                      fontWeight: FontWeight.w800),
                ),
                Text(label, style: const TextStyle(color: AppColors.carbon400, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      enabled: onTap != null,
      tileColor: AppColors.carbon800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.carbon700),
      ),
      leading: Icon(icon, color: onTap == null ? AppColors.carbon600 : AppColors.gold500),
      title: Text(title, style: const TextStyle(color: AppColors.carbon50)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.carbon400)),
      trailing: onTap == null
          ? null
          : const Icon(Icons.chevron_right_rounded, color: AppColors.gold500),
    );
  }
}
