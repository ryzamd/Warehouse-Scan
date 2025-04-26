// lib/features/warehouse_scan/data/datasources/warehouse_out_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:warehouse_scan/core/constants/api_constants.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import 'package:warehouse_scan/features/warehouse_scan/data/models/get_address_list_model.dart';
import '../models/warehouse_out_model.dart';

abstract class WarehouseOutDataSource {

  Future<WarehouseOutModel> getMaterialInfo(String code, String userName);
  
  Future<GetAddressListModel> getAddressList();

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
        throw WarehouseOutException('Server returned error code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException in getMaterialInfo: ${e.message}');
      throw WarehouseOutException(e.message ?? 'Network error');
    } on MaterialNotFoundException {
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error in getMaterialInfo: $e');
      throw WarehouseOutException(e.toString());
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
          throw WarehouseOutException(response.data['message'] ?? 'Processing failed');
        }
      } else {
        throw WarehouseOutException('Server returned error code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException in processWarehouseOut: ${e.message}');
      throw WarehouseOutException(e.message ?? 'Network error');
    } catch (e) {
      debugPrint('Unexpected error in processWarehouseOut: $e');
      throw WarehouseOutException(e.toString());
    }
  }
  
  @override
  Future<GetAddressListModel> getAddressList() async {
    try {
      final response = await dio.post(ApiConstants.getAddressListUrl);
      
      if (response.statusCode == 200) {
        if (response.data['message'].toString().toLowerCase() == 'success') {
          return GetAddressListModel.fromJson(response.data);
        } else {
          throw WarehouseOutException(response.data['message'] ?? 'Get Address failed');
        }
      } else {
        throw WarehouseOutException('Server returned error code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException in getAddressList: ${e.message}');
      throw WarehouseOutException('Network error');
    } catch (e) {
      debugPrint('Unexpected error in getAddressList: $e');
      throw WarehouseOutException(e.toString());
    }
  }
}