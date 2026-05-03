import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../company/presentation/providers/company_provider.dart';
import '../../../company/presentation/screens/company_home_screen.dart';
import '../../../company/presentation/screens/company_info_screen.dart';
import '../../../company/presentation/screens/company_onboarding_screen.dart';
import '../../../network/routes/presentation/screens/company_routes_list_screen.dart';
import '../../../network/stops/presentation/screens/stops_list_screen.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class CompanyMainScreen extends StatefulWidget {
  final bool skipBootstrap;

  const CompanyMainScreen({
    super.key,
    this.skipBootstrap = false,
  });

  @override
  State<CompanyMainScreen> createState() => _CompanyMainScreenState();
}

class _CompanyMainScreenState extends State<CompanyMainScreen> {
  int _selectedIndex = 0;
  bool _bootstrapping = true;

  @override
  void initState() {
    super.initState();
    if (widget.skipBootstrap) {
      _bootstrapping = false;
    } else {
      _bootstrap();
    }
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    final companyProvider = context.read<CompanyProvider>();
    final userId = auth.currentUser?.id;

    if (userId == null || userId.isEmpty) {
      setState(() => _bootstrapping = false);
      return;
    }

    final company = await companyProvider.loadForUser(userId);
    if (!mounted) return;

    if (company == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CompanyOnboardingScreen()),
      );
      return;
    }

    await context.read<UserProvider>().setCompanyId(company.id);
    if (mounted) setState(() => _bootstrapping = false);
  }

  void _openInfo() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CompanyInfoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_bootstrapping) {
      return const Scaffold(
        backgroundColor: AppColors.carbon950,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold500)),
      );
    }

    final screens = [
      CompanyHomeScreen(onOpenInfo: _openInfo),
      const StopsListScreen(),
      const CompanyRoutesListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.carbon900,
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.carbon950,
        border: const Border(top: BorderSide(color: AppColors.carbon700)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
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
              _navItem(0, Icons.dashboard_outlined, 'Inicio'),
              _navItem(1, Icons.pin_drop_outlined, 'Paraderos'),
              _navItem(2, Icons.alt_route_rounded, 'Rutas'),
              _navItem(3, Icons.person_outline_rounded, 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? AppColors.gold500 : AppColors.carbon400, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: selected ? AppColors.gold500 : AppColors.carbon400,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
