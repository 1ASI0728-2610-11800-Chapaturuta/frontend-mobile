import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/company_provider.dart';

class CompanyHomeScreen extends StatelessWidget {
  final VoidCallback onOpenInfo;

  const CompanyHomeScreen({
    super.key,
    required this.onOpenInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyProvider>(
      builder: (context, provider, _) {
        final company = provider.company;
        final stats = provider.stats;

        return RefreshIndicator(
          color: AppColors.gold500,
          onRefresh: provider.refreshStats,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              Text(
                company?.name ?? 'Empresa',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.carbon50,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Panel de gestion movil',
                style: TextStyle(color: AppColors.carbon400),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.pin_drop_outlined,
                      label: 'Paraderos',
                      value: stats.stops.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.alt_route_rounded,
                      label: 'Rutas',
                      value: stats.routes.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _ActionTile(
                icon: Icons.business_rounded,
                title: 'Datos de empresa',
                subtitle: 'Nombre, RUC, contacto y descripcion',
                onTap: onOpenInfo,
              ),
              const SizedBox(height: 12),
              const _ActionTile(
                icon: Icons.route_rounded,
                title: 'Gestion de red',
                subtitle: 'Administra paraderos y rutas desde la barra inferior',
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

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
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
          Icon(icon, color: AppColors.gold500, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.carbon50,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(label, style: const TextStyle(color: AppColors.carbon400)),
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
