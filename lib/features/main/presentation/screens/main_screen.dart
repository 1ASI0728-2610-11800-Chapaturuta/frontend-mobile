import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../routes/presentation/screens/routes_list_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../collections/presentation/screens/collections_screen.dart';
import '../../../reservations/presentation/screens/my_reservations_screen.dart';
import '../../../discovery/presentation/screens/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2;

  static const List<Widget> _screens = [
    SearchScreen(),
    CollectionsScreen(),
    RoutesListScreen(),
    MyReservationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.carbon950,
        border: const Border(
          top: BorderSide(color: AppColors.carbon700, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold600.withValues(alpha:0.10),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _buildNavItem(0, Icons.search_rounded, 'Descubrir'),
              _buildNavItem(1, Icons.folder_outlined, 'Colecciones'),
              _buildNavItem(2, Icons.directions_bus_rounded, 'Rutas'),
              _buildNavItem(3, Icons.confirmation_num_outlined, 'Reservas'),
              _buildNavItem(4, Icons.person_outline_rounded, 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 40 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.gold500,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.gold500 : AppColors.carbon400,
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.gold500 : AppColors.carbon400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
