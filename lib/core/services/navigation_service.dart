import 'package:flutter/material.dart';
import '../constants/app_routes.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();
  
  // QC routes
  String? lastQCRoute;
  // Warehouse routes
  String? lastWarehouseRoute;
  
  String? previousMainRoute;
  bool isInSpecialFeature = false;
  
  void setLastWarehouseRoute(String? route) {
    if (route != null && (route.contains('/warehouse_menu/'))) {
      lastWarehouseRoute = route;
      isInSpecialFeature = route.contains('/export');
    }
  }
  
  void clearLastWarehouseRoute() {
    lastWarehouseRoute = null;
  }
  
  void enterProcessingPageWarehouseIn() {
    previousMainRoute = AppRoutes.processingwarehouseIn;
  }

  void enterProcessingPageWarehouseOut() {
    previousMainRoute = AppRoutes.processingwarehouseOut;
  }

  void enterProcessingPageInventory() {
    previousMainRoute = AppRoutes.processingwarehouseOut;
  }
  
  void enterProfilePage() {
    previousMainRoute = AppRoutes.warehouseMenu;
    clearLastWarehouseRoute();
  }
  
  String getWorkDestination(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    
    switch(currentRoute){
      case AppRoutes.warehouseIn:
      case AppRoutes.warehouseOut:
      case AppRoutes.inventoryCheck:
      case AppRoutes.batchScan:
        return lastWarehouseRoute ?? AppRoutes.warehouseMenu;
    }
    
    if (currentRoute == AppRoutes.profile) {
      return AppRoutes.warehouseMenu;
    }
    
    return lastWarehouseRoute ?? AppRoutes.warehouseMenu;
  }
  
  bool shouldShowBackButton(BuildContext context) {
    String? currentRoute = ModalRoute.of(context)?.settings.name;
    
    if (currentRoute != null && currentRoute.startsWith('/warehouse_menu/')) {
      return true;
    }
    
    if (currentRoute == AppRoutes.warehouseMenu || currentRoute == AppRoutes.profile) {
      return false;
    }
    
    return true;
  }
  
  void handleBackButton(BuildContext context) {
    String? currentRoute = ModalRoute.of(context)?.settings.name;
    
    switch(currentRoute){
      case AppRoutes.warehouseIn:
      case AppRoutes.warehouseOut:
      case AppRoutes.processingwarehouseIn:
      case AppRoutes.processingwarehouseOut:
      case AppRoutes.inventoryCheck:
      case AppRoutes.batchScan:
        Navigator.pop(context);
      break;
    }

    if (currentRoute != null && currentRoute.startsWith('/warehouse_menu/')) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.warehouseMenu,
        arguments: ModalRoute.of(context)?.settings.arguments
      );
    }
  }
}