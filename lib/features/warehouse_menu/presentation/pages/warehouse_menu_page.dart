import 'package:flutter/material.dart';
import 'package:warehouse_scan/core/localization/context_extension.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/widgets/scafford_custom.dart';
import '../../../auth/login/domain/entities/user_entity.dart';

class WarehouseMenuPage extends StatelessWidget {
  final UserEntity user;
  
  const WarehouseMenuPage({super.key, required this.user});
  
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavigationService().clearLastWarehouseRoute();
    });
    
    return CustomScaffold(
      title: context.multiLanguage.warehouseMenuTitle,
      user: user,
      showHomeIcon: false,
      currentIndex: 1,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF283048),
              Color(0xFF859398),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildFunctionTile(
                context,
                title: context.multiLanguage.importMaterialMenuTitle,
                icon: Icons.input,
                route: AppRoutes.warehouseIn,
              ),
              // _buildFunctionTile(
              //   context,
              //   title: context.multiLanguage.exportMaterialMenuTitle,
              //   icon: Icons.output,
              //   route: AppRoutes.warehouseOut,
              // ),
              _buildFunctionTile(
                context,
                title: context.multiLanguage.batchScanMenuTitle,
                icon: Icons.qr_code_scanner,
                route: AppRoutes.batchScan,
              ),
              _buildFunctionTile(
                context,
                title: context.multiLanguage.inventoryMenuTitle,
                icon: Icons.inventory_2,
                route: AppRoutes.inventoryCheck,
              ),
              _buildFunctionTile(
                context,
                title: context.multiLanguage.importUncheckedMenuTitle,
                icon: Icons.playlist_add_check,
                route: AppRoutes.importUnchecked,
              ),
              _buildFunctionTile(
                context,
                title: context.multiLanguage.clearWarehouseMenuTitle,
                icon: Icons.delete_forever,
                route: AppRoutes.clearWarehouse,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFunctionTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: const Color(0xFFEAEAEA),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pushNamed(
            context,
            route,
            arguments: user,
          );
        },
      ),
    );
  }
}