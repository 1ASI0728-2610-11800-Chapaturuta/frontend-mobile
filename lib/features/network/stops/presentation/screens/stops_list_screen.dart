import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../company/presentation/providers/company_provider.dart';
import '../../data/models/company_stop_model.dart';
import '../providers/stop_provider.dart';
import '../widgets/stop_card.dart';
import 'stop_form_screen.dart';
import 'stops_map_screen.dart';

class StopsListScreen extends StatefulWidget {
  const StopsListScreen({super.key});

  @override
  State<StopsListScreen> createState() => _StopsListScreenState();
}

class _StopsListScreenState extends State<StopsListScreen> {
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final company = context.read<CompanyProvider>().company;
    if (company == null) return;
    await context.read<StopProvider>().load(company.id);
  }

  void _openForm([CompanyStopModel? stop]) {
    final company = context.read<CompanyProvider>().company;
    if (company == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StopFormScreen(companyId: company.id, stop: stop),
      ),
    );
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.carbon800,
        title: const Text('Eliminar paradero'),
        content: const Text('Esta accion no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final provider = context.read<StopProvider>();
    final removed = await provider.remove(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(removed ? 'Paradero eliminado' : provider.error ?? 'No se pudo eliminar')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(
        title: const Text('Paraderos'),
        actions: [
          IconButton(
            tooltip: _showMap ? 'Ver lista' : 'Ver mapa',
            onPressed: () => setState(() => _showMap = !_showMap),
            icon: Icon(_showMap ? Icons.list_rounded : Icons.map_outlined),
          ),
          IconButton(
            tooltip: 'Nuevo paradero',
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: Consumer<StopProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.stops.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold500));
          }
          if (provider.error != null && provider.stops.isEmpty) {
            return _MessageState(
              icon: Icons.wifi_off_rounded,
              text: provider.error!,
              onRetry: _load,
            );
          }
          if (_showMap) return const StopsMapScreen();
          if (provider.stops.isEmpty) {
            return _MessageState(
              icon: Icons.pin_drop_outlined,
              text: 'Aun no hay paraderos',
              onRetry: _load,
            );
          }
          return RefreshIndicator(
            color: AppColors.gold500,
            onRefresh: _load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.stops.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final stop = provider.stops[index];
                return StopCard(
                  stop: stop,
                  onEdit: () => _openForm(stop),
                  onDelete: () => _delete(stop.id),
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
