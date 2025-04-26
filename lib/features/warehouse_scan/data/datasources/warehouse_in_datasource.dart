// lib/features/warehouse_scan/data/datasources/warehouse_in_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:warehouse_scan/core/constants/api_constants.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import '../models/warehouse_in_model.dart';

abstract class WarehouseInDataSource {
  /// Send warehouse in data to server
  ///
  /// Throws [WarehouseInException] if operation fails
  Future<WarehouseInModel> processWarehouseIn(String code, String userName);
}

class WarehouseInDataSourceImpl implements WarehouseInDataSource {
  final Dio dio;

  WarehouseInDataSourceImpl({required this.dio});

  @override
  Future<WarehouseInModel> processWarehouseIn(String code, String userName) async {
    try {
      debugPrint('Sending warehouse in request for code: $code');
      
      final response = await dio.post(
        ApiConstants.warehouseInUrl,
        data: {
          'code': code,
          'UserName': userName,
        },
      );
      
      debugPrint('Warehouse in response: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        if (response.data['message'] == 'Success') {
          return WarehouseInModel.fromJson(response.data);
        } else {
          throw WarehouseInException(response.data['message'] ?? 'Processing failed');
        }
      } else {
        throw WarehouseInException('Server returned error code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException in processWarehouseIn: ${e.message}');
      throw WarehouseInException(e.message ?? 'Network error');
    } catch (e) {
      debugPrint('Unexpected error in processWarehouseIn: $e');
      throw WarehouseInException(e.toString());
    }
  }
}