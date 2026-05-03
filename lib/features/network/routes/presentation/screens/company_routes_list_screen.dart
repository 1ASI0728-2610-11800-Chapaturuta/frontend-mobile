import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../company/presentation/providers/company_provider.dart';
import '../../data/models/company_route_model.dart';
import '../providers/company_route_provider.dart';
import 'company_route_form_screen.dart';
import 'company_route_map_screen.dart';

class CompanyRoutesListScreen extends StatefulWidget {
  const CompanyRoutesListScreen({super.key});

  @override
  State<CompanyRoutesListScreen> createState() => _CompanyRoutesListScreenState();
}

class _CompanyRoutesListScreenState extends State<CompanyRoutesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final company = context.read<CompanyProvider>().company;
    if (company == null) return;
    await context.read<CompanyRouteProvider>().load(company.id);
  }

  void _openForm([CompanyRouteModel? route]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CompanyRouteFormScreen(route: route)),
    );
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.carbon800,
        title: const Text('Eliminar ruta'),
        content: const Text('Esta accion no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final provider = context.read<CompanyRouteProvider>();
    final removed = await provider.remove(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(removed ? 'Ruta eliminada' : provider.error ?? 'No se pudo eliminar')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(
        title: const Text('Rutas de empresa'),
        actions: [
          IconButton(
            tooltip: 'Nueva ruta',
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: Consumer<CompanyRouteProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.routes.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold500));
          }
          if (provider.error != null && provider.routes.isEmpty) {
            return _MessageState(icon: Icons.wifi_off_rounded, text: provider.error!, onRetry: _load);
          }
          if (provider.routes.isEmpty) {
            return _MessageState(icon: Icons.alt_route_rounded, text: 'Aun no hay rutas', onRetry: _load);
          }
          return RefreshIndicator(
            color: AppColors.gold500,
            onRefresh: _load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.routes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final route = provider.routes[index];
                return _RouteCard(
                  route: route,
                  onMap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CompanyRouteMapScreen(route: route)),
                  ),
                  onEdit: () => _openForm(route),
                  onDelete: () => _delete(route.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.gold500,
        foregroundColor: AppColors.carbon950,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final CompanyRouteModel route;
  final VoidCallback onMap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RouteCard({
    required this.route,
    required this.onMap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: Row(
        children: [
          const Icon(Icons.alt_route_rounded, color: AppColors.gold500, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.carbon50, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'S/ ${route.price.toStringAsFixed(2)} - ${route.duration} min - ${route.frequency} min',
                  style: const TextStyle(color: AppColors.carbon400, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Mapa',
            onPressed: onMap,
            icon: const Icon(Icons.map_outlined, color: AppColors.gold500),
          ),
          IconButton(
            tooltip: 'Editar',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: AppColors.gold500),
          ),
          IconButton(
            tooltip: 'Eliminar',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String text;
  final Future<void> Function() onRetry;

  const _MessageState({
    required this.icon,
    required this.text,
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
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.carbon400)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
