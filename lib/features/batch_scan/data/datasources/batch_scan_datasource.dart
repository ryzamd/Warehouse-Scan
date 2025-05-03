import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:warehouse_scan/core/constants/api_constants.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import '../../../../core/services/get_translate_key.dart';
import '../models/batch_item_model.dart';
import '../models/batch_process_request_model.dart';
import '../models/batch_process_response_model.dart';

abstract class BatchScanDataSource {
  Future<BatchItemModel> checkCode(String code, String userName);
  Future<BatchProcessResponseModel> processBatch({
    required List<String> codes,
    required String userName,
    required String address,
    required double quantity,
    required int operationMode,
  });
}

class BatchScanDataSourceImpl implements BatchScanDataSource {
  final Dio dio;

  BatchScanDataSourceImpl({required this.dio});

  @override
  Future<BatchItemModel> checkCode(String code, String userName) async {
    try {
      debugPrint('Checking batch item code: $code');
      
      final response = await dio.post(
        ApiConstants.checkCodeUrl,
        data: {
          'code': code,
          'user_name': userName,
        },
      );
      
      if (response.statusCode == 200) {
        if (response.data['message'] == 'Success') {
          return BatchItemModel.fromJson(response.data['data']);
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
  Future<BatchProcessResponseModel> processBatch({
    required List<String> codes,
    required String userName,
    required String address,
    required double quantity,
    required int operationMode,
  }) async {
    try {
      final requestData = codes.map((code) =>
        BatchProcessRequestModel(
          code: code,
          userName: userName,
          address: address,
          qty: quantity,
          number: operationMode,
        ).toJson()
      ).toList();
      
      debugPrint('Processing batch with ${codes.length} items');
      
      final response = await dio.post(
        ApiConstants.batchWarehouseOutUrl,
        data: requestData,
      );
      
      if (response.statusCode == 200) {
        return BatchProcessResponseModel.fromJson(response.data);
      } else {
        throw WarehouseException(StringKey.serverErrorMessage);
      }
    } on DioException catch (_) {
      throw WarehouseException(StringKey.networkErrorMessage);
    }
  }
}