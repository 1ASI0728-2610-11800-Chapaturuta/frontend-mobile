import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'company_main_screen.dart';
import 'main_screen.dart';

class RoleRouterScreen extends StatelessWidget {
  const RoleRouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.carbon950,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.gold500),
        ),
      );
    }

    // Solo dos roles funcionales: Empresa (1) y Pasajero (todo lo demas).
    return user.role == 1 ? const CompanyMainScreen() : const MainScreen();
  }
}
