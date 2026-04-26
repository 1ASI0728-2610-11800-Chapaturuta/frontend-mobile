import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user.dart';
import 'edit_profile_screen.dart';
import 'favorites_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold500));
          }

          final user = provider.currentUser ??
              UserModel(
                id: '0',
                name: 'Usuario',
                lastName: 'Invitado',
                username: 'guest',
                email: 'Sin sesión',
                phone: '',
                gender: '',
                favoriteRoutes: [],
              );

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                _buildAvatar(user),
                const SizedBox(height: 16),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.carbon50,
                    letterSpacing: -0.44,
                  ),
                ),
                const SizedBox(height: 4),
                Text(user.email, style: const TextStyle(fontSize: 14, color: AppColors.carbon400)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold500.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold500.withValues(alpha:0.3)),
                  ),
                  child: const Text(
                    'Viajero',
                    style: TextStyle(color: AppColors.gold400, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildStatsRow(),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gold600, AppColors.gold500, AppColors.gold400],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: AppColors.carbon950,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.carbon800,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.carbon700),
                  ),
                  child: Column(
                    children: [
                      _buildMenuTile(
                        icon: Icons.favorite_rounded,
                        title: 'Mis Favoritos',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuTile(
                        icon: Icons.history_rounded,
                        title: 'Historial de viajes',
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuTile(
                        icon: Icons.star_rounded,
                        title: 'Mis calificaciones',
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notificaciones',
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuTile(
                        icon: Icons.logout_rounded,
                        title: 'Cerrar Sesión',
                        titleColor: AppColors.danger,
                        iconColor: AppColors.danger,
                        showChevron: false,
                        onTap: () => _confirmLogout(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(User user) {
    return Stack(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold500, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold500.withValues(alpha:0.25),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
            image: const DecorationImage(
              image: AssetImage('assets/images/chapaturutalogo.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.gold500,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit_rounded, size: 14, color: AppColors.carbon950),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem('0', 'Viajes'),
        _buildStatDivider(),
        _buildStatItem('0', 'Colecciones'),
        _buildStatDivider(),
        _buildStatItem('0', 'Reseñas'),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.gold500,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.carbon400)),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 32, color: AppColors.carbon700);
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
    bool showChevron = true,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.gold500).withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.gold500, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.carbon100,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      trailing: showChevron
          ? const Icon(Icons.chevron_right_rounded, color: AppColors.gold500, size: 20)
          : null,
      onTap: onTap,
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.carbon800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.carbon50)),
        content: const Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: TextStyle(color: AppColors.carbon200),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.carbon400)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      final userProvider = context.read<UserProvider>();
      final authProvider = context.read<AuthProvider>();
      await userProvider.logout();
      await authProvider.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
