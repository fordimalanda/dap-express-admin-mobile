import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../orders/screens/orders_screen.dart';
import '../../products/screens/products_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../notifications/bloc/notifications_bloc.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    OrdersScreen(),
    ProductsScreen(),
    NotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, notifState) {
          final unread = notifState is NotificationsLoaded ? notifState.unreadCount : 0;

          return NavigationBar(
            selectedIndex: _currentIndex,
            indicatorColor: AppColors.primaryLight,
            onDestinationSelected: (idx) {
              setState(() => _currentIndex = idx);
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
                label: 'Dashboard',
              ),
              const NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag, color: AppColors.primary),
                label: 'Commandes',
              ),
              const NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2, color: AppColors.primary),
                label: 'Produits',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.notifications_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.notifications, color: AppColors.primary),
                ),
                label: 'Alertes',
              ),
            ],
          );
        },
      ),
    );
  }
}
