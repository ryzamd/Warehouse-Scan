import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:warehouse_scan/core/constants/api_constants.dart';
import 'package:warehouse_scan/core/errors/server_exception.dart';
import 'package:warehouse_scan/core/services/secure_storage_service.dart';
import 'package:warehouse_scan/core/di/dependencies.dart' as di;
import '../models/processing_item_model.dart';

abstract class ProcessingRemoteDataSource {
  Future<List<ProcessingItemModel>> getProcessingItems(String date);
}

class ProcessingRemoteDataSourceImpl implements ProcessingRemoteDataSource {
  final Dio dio;
  final bool useMockData;

  ProcessingRemoteDataSourceImpl({required this.dio, this.useMockData = false});

  @override
  Future<List<ProcessingItemModel>> getProcessingItems(String date) async {
    final token = await di.sl<SecureStorageService>().getAccessTokenAsync();
     
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      
      return [
        ProcessingItemModel(
          mwhId: 1693,
          mName: "丁香紫13-4110TPG 網布 DJT-8540 ANTIO TEX (EPM 100%) 270G 44\"",
          mDate: "2024-03-02T00:00:00",
          mVendor: "DONGJIN-USD",
          mPrjcode: "P-452049",
          mQty: 50.5,
          mUnit: "碼/YRD",
          mDocnum: "75689",
          mItemcode: "CA0400076011019",
          cDate: "2024-03-04T10:36:48.586568",
          code: "9f60778799d34d70adaf8ba5adcb0dcd",
          qcQtyIn: 0,
          qcQtyOut: 0,
          zcWarehouseQtyImport: 0,
          zcWarehouseQtyExport: 0,
          qtyState: "未質檢",
        ),
      ];
    }

    try {
      final response = await dio.get(
        ApiConstants.getListUrl(date),
        options: Options(
          headers: {"Authorization": "Bearer $token"},
          contentType: 'application/json',
          extra: {'log_request': true}
        ),
      );
    
      debugPrint('Processing API response code: ${response.statusCode}');
      debugPrint('Processing API response data type: ${response.data.runtimeType}');
    
      if (response.statusCode == 200) {
        final List<dynamic> itemsJson = response.data;
        final result = itemsJson.map((itemJson) =>
          ProcessingItemModel.fromJson(itemJson)
        ).toList();
      
        return result;
      } else {
        throw ServerException('Failed to load processing items: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException in getProcessingItems: ${e.message}');
      debugPrint('Request path: ${e.requestOptions.path}');
      debugPrint('Request data: ${e.requestOptions.data}');
      throw ServerException(e.message ?? 'Error fetching processing items');
    } catch (e) {
      debugPrint('Unexpected error in getProcessingItems: $e');
      throw ServerException(e.toString());
    }
  }
}