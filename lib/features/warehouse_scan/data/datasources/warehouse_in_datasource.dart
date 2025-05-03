import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:warehouse_scan/core/constants/api_constants.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import '../../../../core/services/get_translate_key.dart';
import '../models/warehouse_in_model.dart';

abstract class WarehouseInDataSource {
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
          throw WarehouseInException(StringKey.processingFetchDataFailedMessage);
        }
      } else {
        throw WarehouseInException(StringKey.serverErrorMessage);
      }
    } on DioException catch (e) {
      debugPrint('DioException in processWarehouseIn: ${e.message}');
      throw WarehouseInException(StringKey.networkErrorMessage);
    }
  }
}