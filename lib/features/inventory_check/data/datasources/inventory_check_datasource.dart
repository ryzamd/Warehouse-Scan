import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:warehouse_scan/core/constants/api_constants.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import '../models/inventory_item_model.dart';

abstract class InventoryCheckDataSource {
  Future<InventoryItemModel> checkItemCode(String code, String userName);

  Future<List<InventoryItemModel>> saveInventoryItems(List<String> codes);
}

class InventoryCheckDataSourceImpl implements InventoryCheckDataSource {
  final Dio dio;

  InventoryCheckDataSourceImpl({required this.dio});

  @override
  Future<InventoryItemModel> checkItemCode(String code, String userName) async {
    try {
      debugPrint('Checking inventory item code: $code');
      
      final response = await dio.post(
        ApiConstants.checkCodeUrl,
        data: {
          'code': code,
          'user_name': userName,
        },
      );
      
      if (response.statusCode == 200) {
        if (response.data['message'] == 'Success') {
          return InventoryItemModel.fromJson(response.data['data']);
        } else {
          throw MaterialNotFoundException(code);
        }
      } else {
        throw WarehouseException('Server returned error code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw WarehouseException(e.message ?? 'Network error');
    } on MaterialNotFoundException {
      rethrow;
    } catch (e) {
      throw WarehouseException(e.toString());
    }
  }
  
  @override
  Future<List<InventoryItemModel>> saveInventoryItems(List<String> codes) async {
    try {
      final response = await dio.post(
        ApiConstants.saveInventoryUrl,
        data: codes,
      );
      
      if (response.statusCode == 200) {
        
        if (response.data['message'] == 'Success') {
          final List<dynamic> dataList = response.data['data'];

          return dataList.map((json) => InventoryItemModel.fromJson(json)).toList();

        } else {
          throw WarehouseException(response.data['message'] ?? 'Saving inventory failed');
        }
      } else {
        throw WarehouseException('Server returned error code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw WarehouseException(e.message ?? 'Network error');
    } catch (e) {
      throw WarehouseException(e.toString());
    }
  }
}