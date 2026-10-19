import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/alerts/presentation/alerts_screen.dart';
import '../../features/auth/domain/user_model.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/cash_register/presentation/cash_register_screen.dart';
import '../../features/customers/presentation/customers_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/inventory/presentation/movements_screen.dart';
import '../../features/inventory/presentation/stock_adjustment_screen.dart';
import '../../features/inventory/presentation/stock_levels_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/purchases/presentation/purchases_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/settings/presentation/network_config_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/suppliers/presentation/suppliers_screen.dart';
import '../theme/app_colors.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuth && !isLoggingIn) {
        return '/login';
      }

      if (isAuth && isLoggingIn) {
        if (authState.user?.role == UserRole.caissier) {
          return '/caisse';
        }
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return _ScaffoldWithNavBar(child: child, user: authState.user);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/caisse',
            builder: (context, state) => const CashRegisterScreen(),
          ),
          GoRoute(
            path: '/produits',
            builder: (context, state) => const ProductsScreen(),
          ),
          GoRoute(
            path: '/stock',
            builder: (context, state) => const StockLevelsScreen(),
          ),
          GoRoute(
            path: '/approvisionnements',
            builder: (context, state) => const PurchasesScreen(),
          ),
          GoRoute(
            path: '/rapports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/parametres',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      // Routes secondaires
      GoRoute(
        path: '/alertes',
        builder: (context, state) => const AlertsScreen(),
      ),
      GoRoute(
        path: '/clients',
        builder: (context, state) => const CustomersScreen(),
      ),
      GoRoute(
        path: '/fournisseurs',
        builder: (context, state) => const SuppliersScreen(),
      ),
      GoRoute(
        path: '/stock-ajuster',
        builder: (context, state) => const StockAdjustmentScreen(),
      ),
      GoRoute(
        path: '/mouvements',
        builder: (context, state) => const MovementsScreen(),
      ),
      GoRoute(
        path: '/reseau',
        builder: (context, state) => const NetworkConfigScreen(),
      ),
    ],
  );
});

class _ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  final UserModel? user;

  const _ScaffoldWithNavBar({required this.child, this.user});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/caisse')) return 1;
    if (location.startsWith('/produits') || location.startsWith('/stock')) return 2;
    if (location.startsWith('/approvisionnements')) return 3;
    if (location.startsWith('/rapports')) return 4;
    if (location.startsWith('/parametres')) return 5;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/caisse');
        break;
      case 2:
        context.go('/produits');
        break;
      case 3:
        context.go('/approvisionnements');
        break;
      case 4:
        context.go('/rapports');
        break;
      case 5:
        context.go('/parametres');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCaissierOnly = user?.role == UserRole.caissier;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
        indicatorColor: AppColors.primary.withOpacity(0.18),
        destinations: isCaissierOnly
            ? const [
                NavigationDestination(
                  icon: Icon(Icons.point_of_sale_outlined),
                  selectedIcon: Icon(Icons.point_of_sale, color: AppColors.primary),
                  label: 'Caisse POS',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2, color: AppColors.primary),
                  label: 'Produits',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings, color: AppColors.primary),
                  label: 'Paramètres',
                ),
              ]
            : const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
                  label: 'Tableau',
                ),
                NavigationDestination(
                  icon: Icon(Icons.point_of_sale_outlined),
                  selectedIcon: Icon(Icons.point_of_sale, color: AppColors.primary),
                  label: 'Caisse',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2, color: AppColors.primary),
                  label: 'Stock',
                ),
                NavigationDestination(
                  icon: Icon(Icons.local_shipping_outlined),
                  selectedIcon: Icon(Icons.local_shipping, color: AppColors.primary),
                  label: 'Achats',
                ),
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics, color: AppColors.primary),
                  label: 'IA & Rapports',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings, color: AppColors.primary),
                  label: 'Profil',
                ),
              ],
      ),
    );
  }
}
