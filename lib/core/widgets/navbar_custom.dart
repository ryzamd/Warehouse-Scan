import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import '../services/navigation_service.dart';
import '../../features/auth/login/domain/entities/user_entity.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final UserEntity? user;
  final bool disableNavigation;
  final bool showHomeIcon;
  final Function(int)? customCallback;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    this.user,
    this.disableNavigation = false,
    required this.showHomeIcon,
    this.customCallback,
  });

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();
    
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF4158A6)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (showHomeIcon)
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                index: 0,
                route: navigationService.isInSpecialFeature ? AppRoutes.processingwarehouseOut : AppRoutes.processingwarehouseIn,
              ),
              
              _buildNavItem(
                context,
                icon: Icons.work_rounded,
                selectedIcon: Icons.work_rounded,
                index: 1,
                route: AppRoutes.warehouseMenu,
              ),
              
              if (!showHomeIcon)
              _buildNavItem(
                context,
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                index: 2,
                route: AppRoutes.profile,
                badge: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required int index,
    required String route,
    bool badge = false,
  }) {
    final isSelected = currentIndex == index;
    final navigationService = NavigationService();

    return InkWell(
      onTap: disableNavigation ? null : () {
        if (!isSelected) {
          String destination = route;
          
          if (index == 1 && route == AppRoutes.warehouseMenu) {
            destination = navigationService.getWorkDestination(context);
          }
          
          if (index == 2 && route == AppRoutes.profile) {
            navigationService.enterProfilePage();
          }
          
          Navigator.of(context).pushReplacementNamed(
            destination,
            arguments: user,
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}