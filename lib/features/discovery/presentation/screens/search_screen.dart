import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../../routes/data/models/route_model.dart';
import '../../../routes/presentation/screens/route_detail_screen.dart';
import '../../data/models/search_result_model.dart';
import '../providers/discovery_provider.dart';
import 'assistant_screen.dart';

/// "Descubrir": origin/destination search backed by /discovery/search plus popular
/// routes from /discovery/popular. Tapping a result opens the route detail → reserve → pay.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _originController = TextEditingController();
  final _destController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPopular());
  }

  @override
  void dispose() {
    _originController.dispose();
    _destController.dispose();
    super.dispose();
  }

  int? get _userId {
    final raw = context.read<UserProvider>().currentUser?.id;
    return raw == null ? null : int.tryParse(raw);
  }

  Future<void> _loadPopular() async {
    final userId = _userId;
    if (userId == null) return;
    await context.read<DiscoveryProvider>().loadPopular(userId);
  }

  Future<void> _search() async {
    final userId = _userId;
    if (userId == null) return;
    FocusScope.of(context).unfocus();
    await context.read<DiscoveryProvider>().search(
          userId,
          origin: _originController.text.trim(),
          destination: _destController.text.trim(),
        );
  }

  void _openRoute(int routeId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RouteDetailScreen(routeId: routeId.toString())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.gold500,
          onRefresh: _loadPopular,
          child: Consumer<DiscoveryProvider>(
            builder: (context, provider, _) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHero(),
                  if (provider.quotaMessage != null) _quotaBanner(provider.quotaMessage!),
                  if (provider.hasSearched)
                    _buildSearchResults(provider)
                  else
                    _buildPopular(provider),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.carbon950, AppColors.carbon900],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Descubrir',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.carbon50, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          const Text('Encuentra tu ruta de origen a destino',
              style: TextStyle(color: AppColors.carbon400, fontSize: 14)),
          const SizedBox(height: 16),
          _searchField(_originController, 'Origen', Icons.radio_button_checked, AppColors.success),
          const SizedBox(height: 10),
          _searchField(_destController, 'Destino', Icons.location_on_rounded, AppColors.gold500),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.search_rounded, size: 20),
              label: const Text('Buscar rutas'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AssistantScreen()),
              ),
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text('Asistente IA de viajes'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold500,
                side: const BorderSide(color: AppColors.gold500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField(TextEditingController controller, String hint, IconData icon, Color iconColor) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.carbon50),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildPopular(DiscoveryProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Rutas populares'),
        if (provider.loadingPopular)
          _loadingList()
        else if (provider.popular.isEmpty)
          _empty('Aún no hay rutas populares')
        else
          ...provider.popular.map((r) => _routeTile(
                route: r,
                onTap: () => _openRoute(r.id),
              )),
      ],
    );
  }

  Widget _buildSearchResults(DiscoveryProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Expanded(child: _sectionHeaderText('Resultados')),
              TextButton.icon(
                onPressed: provider.clearSearch,
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Limpiar'),
                style: TextButton.styleFrom(foregroundColor: AppColors.carbon400),
              ),
            ],
          ),
        ),
        if (provider.loadingSearch)
          _loadingList()
        else if (provider.error != null)
          _empty(provider.error!)
        else if (provider.results.isEmpty)
          _empty('No se encontraron rutas para tu búsqueda')
        else
          ...provider.results.map((res) => _routeTile(
                route: res.route,
                subtitle: _estimateLabel(res),
                onTap: () => _openRoute(res.route.id),
              )),
      ],
    );
  }

  String? _estimateLabel(SearchResultModel res) {
    final parts = <String>[];
    if (res.estimatedDistanceLabel != null) parts.add(res.estimatedDistanceLabel!);
    if (res.estimatedDurationLabel != null) parts.add('~${res.estimatedDurationLabel!}');
    return parts.isEmpty ? null : parts.join(' · ');
  }

  Widget _routeTile({
    required TransportRouteModel route,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.carbon800,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.carbon700),
          ),
          child: Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: AppColors.gold500.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_bus_rounded, color: AppColors.gold500),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(route.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.carbon50, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle ??
                          [route.duration, route.distance].where((s) => s.isNotEmpty).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.carbon400, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('S/ ${route.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppColors.gold500, fontWeight: FontWeight.w800, fontSize: 15)),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.carbon600),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: _sectionHeaderText(text),
      );

  Widget _sectionHeaderText(String text) => Text(text,
      style: const TextStyle(color: AppColors.carbon100, fontSize: 18, fontWeight: FontWeight.w700));

  Widget _quotaBanner(String message) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_outlined, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.carbon100, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _loadingList() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: List.generate(
          4,
          (_) => Container(
            height: 74,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            decoration: BoxDecoration(
              color: AppColors.carbon800,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _empty(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 40, color: AppColors.carbon600),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.carbon400)),
          ],
        ),
      ),
    );
  }
}
