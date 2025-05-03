import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:warehouse_scan/core/constants/api_constants.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import '../../../../core/services/get_translate_key.dart';
import '../models/warehouse_out_model.dart';

abstract class WarehouseOutDataSource {

  Future<WarehouseOutModel> getMaterialInfo(String code, String userName);
  
  Future<bool> processWarehouseOut({
    required String code,
    required String address,
    required double quantity,
    required String userName,
    required int optionFunction,
  });
}

class WarehouseOutDataSourceImpl implements WarehouseOutDataSource {
  final Dio dio;

  WarehouseOutDataSourceImpl({required this.dio});

  @override
  Future<WarehouseOutModel> getMaterialInfo(String code, String userName) async {
    try {
      debugPrint('Getting material info for code: $code');
      
      final response = await dio.post(
        ApiConstants.checkCodeUrl,
        data: {
          'code': code,
          'user_name': userName,
        },
      );
      
      debugPrint('Get material info response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        if (response.data['message'] == 'Success') {
          return WarehouseOutModel.fromJson(response.data['data']);
        } else {
          throw MaterialNotFoundException(code);
        }
      } else {
        throw WarehouseInException(StringKey.processingFetchDataFailedMessage);
      }
    } on DioException catch (e) {
      debugPrint('DioException in getMaterialInfo: ${e.message}');
     throw WarehouseInException(StringKey.networkErrorMessage);
    }
  }
  
  @override
  Future<bool> processWarehouseOut({
    required String code,
    required String address,
    required double quantity,
    required String userName,
    required int optionFunction,
  }) async {
    try {
      debugPrint('Processing warehouse out for code: $code');
      
      final response = await dio.post(
        ApiConstants.warehouseOutUrl,
        data: {
          'code': code,
          'UserName': userName,
          'address': address,
          'qty': quantity,
          'number': optionFunction,
        },
      );
      
      debugPrint('Process warehouse out response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        if (response.data['message'] == 'Success') {
          return true;
        } else {
          throw WarehouseInException(StringKey.processingFetchDataFailedMessage);
        }
      } else {
        throw WarehouseOutException(StringKey.serverErrorMessage);
      }
    } on DioException catch (e) {
      debugPrint('DioException in processWarehouseOut: ${e.message}');
      throw WarehouseOutException(StringKey.networkErrorMessage);
    }
  }
}