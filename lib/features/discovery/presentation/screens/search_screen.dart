import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _originController = TextEditingController();
  final _destController = TextEditingController();

  @override
  void dispose() {
    _originController.dispose();
    _destController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHero()),
            SliverToBoxAdapter(child: _buildPopularSection()),
          ],
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Descubrir',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.carbon50,
              letterSpacing: -0.56,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '¿A dónde vas hoy?',
            style: TextStyle(fontSize: 14, color: AppColors.carbon400),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: AppColors.carbon800,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.carbon700),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSearchField(
                  controller: _originController,
                  hint: 'Origen',
                  icon: Icons.radio_button_checked,
                  iconColor: AppColors.success,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                  child: Row(
                    children: [
                      Container(width: 1, height: 20, color: AppColors.carbon700, margin: const EdgeInsets.only(left: 10)),
                    ],
                  ),
                ),
                _buildSearchField(
                  controller: _destController,
                  hint: 'Destino',
                  icon: Icons.location_on_rounded,
                  iconColor: AppColors.gold500,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gold600, AppColors.gold500, AppColors.gold400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold500.withValues(alpha:0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: AppColors.carbon950,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.search_rounded, size: 20),
                      label: const Text('Buscar ruta', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.carbon100, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.carbon400),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              filled: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rutas populares',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.carbon50,
                  letterSpacing: -0.36,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Ver todas', style: TextStyle(color: AppColors.gold400, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // TODO: endpoint pendiente de implementación en backend (/api/discovery/popular)
          ...List.generate(3, (i) => _buildPopularShimmer()),
        ],
      ),
    );
  }

  Widget _buildPopularShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.carbon800,
      highlightColor: AppColors.gold500.withValues(alpha:0.15),
      child: Container(
        height: 72,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.carbon800,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
