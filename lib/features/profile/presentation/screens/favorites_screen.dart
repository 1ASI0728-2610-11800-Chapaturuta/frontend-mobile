import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../routes/presentation/providers/route_provider.dart';
import '../../../routes/presentation/widgets/route_card.dart';
import '../../../routes/presentation/screens/route_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<RouteProvider>(
        builder: (context, provider, child) {
          final favorites = provider.favoriteRoutes;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_outline_rounded, size: 64, color: AppColors.carbon600),
                  const SizedBox(height: 16),
                  const Text('Sin rutas guardadas', style: TextStyle(color: AppColors.carbon400, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Guarda rutas para acceder rápido', style: TextStyle(color: AppColors.carbon600, fontSize: 13)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final route = favorites[index];
              return SizedBox(
                height: 260,
                child: RouteCard(
                  route: route,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RouteDetailScreen(routeId: route.id.toString())),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
