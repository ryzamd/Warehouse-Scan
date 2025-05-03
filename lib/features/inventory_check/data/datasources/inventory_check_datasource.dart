import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:warehouse_scan/core/constants/api_constants.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import 'package:warehouse_scan/core/services/get_translate_key.dart';
import '../models/inventory_item_model.dart';
import '../models/batch_inventory_response_model.dart';

abstract class InventoryCheckDataSource {
  Future<InventoryItemModel> checkItemCode(String code, String userName);
  Future<BatchInventoryResponseModel> saveInventoryItems(List<String> codes);
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
        throw WarehouseException(StringKey.serverErrorMessage);
      }
    } on DioException catch (_) {
      throw WarehouseException(StringKey.networkErrorMessage);
    }
  }
  
  @override
  Future<BatchInventoryResponseModel> saveInventoryItems(List<String> codes) async {
    try {
      final response = await dio.post(
        ApiConstants.saveInventoryUrl,
        data: codes,
      );
      
      if (response.statusCode == 200) {
        return BatchInventoryResponseModel.fromJson(response.data);
      } else {
        throw WarehouseException(StringKey.serverErrorMessage);
      }
    } on DioException catch (_) {
      throw WarehouseException(StringKey.networkErrorMessage);
    }
  }
}