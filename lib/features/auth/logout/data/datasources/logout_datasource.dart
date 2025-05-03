import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse_scan/core/network/dio_client.dart';
import 'package:warehouse_scan/features/warehouse_scan/data/datasources/scan_service_impl.dart';

abstract class LogoutDataSource {
  
  Future<bool> logout();
}

class LogoutDataSourceImpl implements LogoutDataSource {
  final SharedPreferences sharedPreferences;
  final DioClient dioClient;

  LogoutDataSourceImpl({
    required this.sharedPreferences,
    required this.dioClient,
  });

  @override
  Future<bool> logout() async {
    try {
      dioClient.clearAuthToken();
      
      ScanService.disposeScannerListener();
      
      await sharedPreferences.remove('user_token');
      
      final userId = sharedPreferences.getString('current_user_id');
      if (userId != null) {
        await sharedPreferences.remove('scan_records_$userId');
        await sharedPreferences.remove('current_user_id');
      }
      
      return true;
    } catch (e) {
      debugPrint('Error during logout: $e');
      return false;
    }
  }
}