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
import '../../../trips/presentation/screens/trip_history_screen.dart';
import '../../../subscriptions/presentation/screens/subscriptions_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

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
      final userProvider = context.read<UserProvider>();
      final authProvider = context.read<AuthProvider>();
      userProvider.loadCurrentUser();
      if (authProvider.token != null) {
        userProvider.setToken(authProvider.token!);
      }
      userProvider.loadProfileStats();
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
                email: 'Sin sesion',
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
                _buildRoleBadge(user),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildStatsRow(provider.stats),
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
                        onPressed: () async {
                          final provider = context.read<UserProvider>();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          );
                          if (mounted) {
                            provider.loadCurrentUser();
                          }
                        },
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TripHistoryScreen()),
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuTile(
                        icon: Icons.star_rounded,
                        title: 'Mis calificaciones',
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuTile(
                        icon: Icons.workspace_premium_rounded,
                        title: 'Planes y suscripción',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notificaciones',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuTile(
                        icon: Icons.logout_rounded,
                        title: 'Cerrar Sesion',
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

  Widget _buildRoleBadge(User user) {
    final Color bgColor;
    final Color textColor;
    final IconData icon;

    switch (user.role) {
      case 2:
        bgColor = const Color(0xFF1A3A2A);
        textColor = const Color(0xFF4ADE80);
        icon = Icons.directions_car_rounded;
        break;
      case 3:
        bgColor = const Color(0xFF2A1A3A);
        textColor = const Color(0xFFBB86FC);
        icon = Icons.admin_panel_settings_rounded;
        break;
      default:
        bgColor = AppColors.gold500.withValues(alpha: 0.15);
        textColor = AppColors.gold400;
        icon = Icons.person_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            user.roleLabel,
            style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(User user) {
    final initials = _getInitials(user);
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
                color: AppColors.gold500.withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.gold600, AppColors.gold500],
            ),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.carbon950,
              ),
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
            child: const Icon(Icons.camera_alt_rounded, size: 14, color: AppColors.carbon950),
          ),
        ),
      ],
    );
  }

  String _getInitials(User user) {
    final name = user.name.trim();
    final lastName = user.lastName.trim();
    if (name.isEmpty && lastName.isEmpty) {
      return user.username.isNotEmpty ? user.username[0].toUpperCase() : '?';
    }
    final first = name.isNotEmpty ? name[0].toUpperCase() : '';
    final second = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$second';
  }

  Widget _buildStatsRow(ProfileStats stats) {
    return Row(
      children: [
        _buildStatItem('${stats.trips}', 'Viajes'),
        _buildStatDivider(),
        _buildStatItem('${stats.collections}', 'Colecciones'),
        _buildStatDivider(),
        _buildStatItem('${stats.ratings}', 'Resenas'),
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
          color: (iconColor ?? AppColors.gold500).withValues(alpha: 0.1),
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
        title: const Text('Cerrar Sesion', style: TextStyle(color: AppColors.carbon50)),
        content: const Text(
          'Estas seguro que deseas cerrar sesion?',
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
            child: const Text('Cerrar Sesion', style: TextStyle(color: Colors.white)),
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
