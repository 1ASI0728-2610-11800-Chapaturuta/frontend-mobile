import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/data/datasources/auth_api_service.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';

import 'features/routes/data/datasources/route_api_service.dart';
import 'features/routes/data/repositories/route_repository_impl.dart';
import 'features/routes/presentation/providers/route_provider.dart';

import 'features/profile/data/repositories/user_repository_impl.dart';
import 'features/profile/presentation/providers/user_provider.dart';

import 'features/driver/data/datasources/driver_api_service.dart';
import 'features/driver/data/repositories/driver_repository_impl.dart';
import 'features/driver/presentation/providers/driver_provider.dart';
import 'features/main/presentation/screens/role_router_screen.dart';
import 'features/network/routes/data/datasources/company_route_api_service.dart';
import 'features/network/routes/presentation/providers/company_route_provider.dart';
import 'features/network/stops/data/datasources/stop_api_service.dart';
import 'features/network/stops/presentation/providers/stop_provider.dart';
import 'features/reservations/data/datasources/reservation_api_service.dart';
import 'features/reservations/presentation/providers/reservation_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final routeApiService = RouteApiService();
    final driverApiService = DriverApiService();
    final stopApiService = StopApiService();
    final companyRouteApiService = CompanyRouteApiService();
    final reservationApiService = ReservationApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            repository: AuthRepositoryImpl(apiService: AuthApiService()),
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (_) => UserProvider(
            repository: UserRepositoryImpl(),
          )..loadCurrentUser(),
          update: (context, authProvider, previousUserProvider) {
            if (authProvider.token != null) {
              previousUserProvider!.setToken(authProvider.token!);
            }
            return previousUserProvider!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, RouteProvider>(
          create: (context) => RouteProvider(
            repository: RouteRepositoryImpl(apiService: routeApiService),
            apiService: routeApiService,
          ),
          update: (context, authProvider, previousRouteProvider) {
            if (authProvider.token != null) {
              routeApiService.setBearerToken(authProvider.token!);
            }
            return previousRouteProvider!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, DriverProvider>(
          create: (context) => DriverProvider(
            repository: DriverRepositoryImpl(apiService: driverApiService),
          ),
          update: (context, authProvider, previousDriverProvider) {
            if (authProvider.token != null) {
              driverApiService.setBearerToken(authProvider.token!);
            }
            return previousDriverProvider!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, StopProvider>(
          create: (context) => StopProvider(apiService: stopApiService),
          update: (context, authProvider, previousStopProvider) {
            if (authProvider.token != null) {
              stopApiService.setBearerToken(authProvider.token!);
            }
            return previousStopProvider!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, CompanyRouteProvider>(
          create: (context) => CompanyRouteProvider(apiService: companyRouteApiService),
          update: (context, authProvider, previousRouteProvider) {
            if (authProvider.token != null) {
              companyRouteApiService.setBearerToken(authProvider.token!);
            }
            return previousRouteProvider!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ReservationProvider>(
          create: (context) => ReservationProvider(apiService: reservationApiService),
          update: (context, authProvider, previousReservationProvider) {
            if (authProvider.token != null) {
              reservationApiService.setBearerToken(authProvider.token!);
            }
            return previousReservationProvider!;
          },
        ),
      ],
      child: MaterialApp(
        title: 'ChapaTuRuta',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.loadCurrentUser();

    if (mounted) {
      if (userProvider.currentUser != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RoleRouterScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon950,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 80,
              child: Image.asset(
                'assets/images/chapaturuta.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.gold500,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
