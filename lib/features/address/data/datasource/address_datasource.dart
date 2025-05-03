import 'package:dio/dio.dart';
import 'package:warehouse_scan/core/constants/api_constants.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import 'package:warehouse_scan/core/services/get_translate_key.dart';
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
          throw WarehouseException(StringKey.getAddressListFailedMessage);
        }
      } else {
        throw WarehouseException(StringKey.serverErrorMessage);
      }
    } on DioException catch (_) {
      throw WarehouseException(StringKey.networkErrorMessage);
    }
  }
}