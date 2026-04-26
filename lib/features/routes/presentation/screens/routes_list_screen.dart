import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/route_provider.dart';
import '../widgets/route_card.dart';
import 'route_detail_screen.dart';

class RoutesListScreen extends StatefulWidget {
  const RoutesListScreen({super.key});

  @override
  State<RoutesListScreen> createState() => _RoutesListScreenState();
}

class _RoutesListScreenState extends State<RoutesListScreen> {
  final List<String> regions = ['', 'Lima', 'Callao', 'Arequipa'];
  final List<String> provinces = ['', 'Lima', 'Callao', 'Arequipa'];
  final List<String> districts = [
    '', 'San Isidro', 'Miraflores', 'Callao', 'Santiago de Surco',
    'Los Olivos', 'Chorrillos', 'Ate', 'Pueblo Libre',
    'San Juan de Lurigancho', 'San Borja',
  ];
  final List<String> localities = [
    '', 'San Isidro Centro', 'Miraflores', 'Callao Centro', 'Surco',
    'Los Olivos', 'Chorrillos', 'Ate Vitarte', 'Pueblo Libre', 'SJL', 'San Borja',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RouteProvider>().loadRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      body: SafeArea(
        child: Consumer<RouteProvider>(
          builder: (context, provider, child) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildFilters(provider)),
                if (provider.isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.62,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => _buildShimmerCard(),
                        childCount: 6,
                      ),
                    ),
                  )
                else if (provider.error != null)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off_rounded, color: AppColors.carbon600, size: 48),
                          const SizedBox(height: 12),
                          Text(provider.error!, style: const TextStyle(color: AppColors.carbon400)),
                        ],
                      ),
                    ),
                  )
                else if (provider.routes.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_bus_outlined, color: AppColors.carbon600, size: 48),
                          SizedBox(height: 12),
                          Text('No se encontraron rutas', style: TextStyle(color: AppColors.carbon400)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.62,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final route = provider.routes[index];
                          return _AnimatedListItem(
                            index: index,
                            child: RouteCard(
                              route: route,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RouteDetailScreen(routeId: route.id.toString()),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: provider.routes.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          SizedBox(
            height: 36,
            child: Image.asset('assets/images/chapaturuta.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Rutas disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.carbon50,
                letterSpacing: -0.36,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(RouteProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown('Región', provider.selectedRegion, regions,
                    (v) => provider.setRegion(v?.isEmpty == true ? null : v)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown('Provincia', provider.selectedProvince, provinces,
                    (v) => provider.setProvince(v?.isEmpty == true ? null : v)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown('Distrito', provider.selectedDistrict, districts,
                    (v) => provider.setDistrict(v?.isEmpty == true ? null : v)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown('Localidad', provider.selectedLocality, localities,
                    (v) => provider.setLocality(v?.isEmpty == true ? null : v)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gold600, AppColors.gold500, AppColors.gold400],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold500.withValues(alpha:0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => provider.filterRoutes(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppColors.carbon950,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.search_rounded, size: 20),
                label: const Text('Buscar rutas', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.carbon400, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.carbon800,
            border: Border.all(color: AppColors.carbon700),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value ?? '',
              isExpanded: true,
              dropdownColor: AppColors.carbon800,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.carbon400, size: 18),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item.isEmpty ? 'Todos' : item,
                          style: TextStyle(
                            fontSize: 12,
                            color: item.isEmpty ? AppColors.carbon400 : AppColors.carbon100,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.carbon800,
      highlightColor: AppColors.gold500.withValues(alpha:0.15),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.carbon800,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedListItem({required this.index, required this.child});

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutExpo),
    );

    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
