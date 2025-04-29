import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:warehouse_scan/core/constants/api_constants.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import '../models/address_model.dart';

abstract class AddressDataSource {
  Future<AddressModel> getAddressList();
}

class AddressDataSourceImpl implements AddressDataSource {
  final Dio dio;

  AddressDataSourceImpl({required this.dio});

  @override
  Future<AddressModel> getAddressList() async {
    try {
      final response = await dio.post(ApiConstants.getAddressListUrl);
      
      if (response.statusCode == 200) {
        if (response.data['message'].toString().toLowerCase() == 'success') {
          return AddressModel.fromJson(response.data);
        } else {
          throw WarehouseException(response.data['message'] ?? 'Get Address failed');
        }
      } else {
        throw WarehouseException('Server returned error code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException in getAddressList: ${e.message}');
      throw WarehouseException('Network error');
    } catch (e) {
      debugPrint('Unexpected error in getAddressList: $e');
      throw WarehouseException(e.toString());
    }
  }
}