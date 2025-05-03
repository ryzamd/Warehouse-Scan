import 'package:flutter/material.dart';
import 'package:warehouse_scan/core/auth/auth_repository.dart';
import 'package:warehouse_scan/core/di/dependencies.dart' as di;
import '../datasources/logout_datasource.dart';
import '../../domain/repositories/logout_repository.dart';

class LogoutRepositoryImpl implements LogoutRepository {
  final LogoutDataSource dataSource;

  LogoutRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<bool> logout() async {
    try {
      return await di.sl<AuthRepository>().logout();
      
    } catch (e) {
      debugPrint('Error during logout: $e');
      return false;
    }
  }
}