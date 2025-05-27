import 'package:dio/dio.dart';
import 'package:warehouse_scan/core/constants/api_constants.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import '../../../../core/services/get_translate_key.dart';
import '../models/clear_warehouse_item_model.dart';

abstract class ClearWarehouseDataSource {
  Future<ClearWarehouseItemModel> checkWarehouseItem(String code, String userName);
  Future<bool> clearWarehouseQuantity(String code, String userName);
}

class ClearWarehouseDataSourceImpl implements ClearWarehouseDataSource {
  final Dio dio;

  ClearWarehouseDataSourceImpl({required this.dio});

  @override
  Future<ClearWarehouseItemModel> checkWarehouseItem(String code, String userName) async {
    try {
      final response = await dio.post(
        ApiConstants.checkCodeUrl,
        data: {
          'code': code,
          'user_name': userName,
        },
      );
      
      if (response.statusCode == 200) {
        if (response.data['message'] == 'Success') {
          return ClearWarehouseItemModel.fromJson(response.data['data']);
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
  Future<bool> clearWarehouseQuantity(String code, String userName) async {
    try {
      final response = await dio.post(
        ApiConstants.clearWarehouseQuantityUrl,
        data: {
          'post_zc_code': code,
          'post_zc_UserName': userName,
        },
      );
      
      if (response.statusCode == 200) {
        if (response.data['message'] == 'Success') {
          return true;
        } else {
          throw WarehouseException(response.data['message']);
        }
      } else {
        throw WarehouseException(StringKey.serverErrorMessage);
      }
    } on DioException catch (_) {
      throw WarehouseException(StringKey.networkErrorMessage);
    }
  }
}