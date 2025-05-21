import 'package:dio/dio.dart';
import 'package:warehouse_scan/core/constants/api_constants.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import '../../../../core/services/get_translate_key.dart';
import '../models/import_unchecked_item_model.dart';
import '../models/import_unchecked_response_model.dart';

abstract class ImportUncheckedDataSource {
  Future<ImportUncheckedItemModel> checkItemCodeDataSource(String code, String userName);
  Future<ImportUncheckedResponseModel> importUncheckedDataSource(List<String> codes, String userName);
}

class ImportUncheckedDataSourceImpl implements ImportUncheckedDataSource {
  final Dio dio;

  ImportUncheckedDataSourceImpl({required this.dio});

  @override
  Future<ImportUncheckedItemModel> checkItemCodeDataSource(String code, String userName) async {
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
          return ImportUncheckedItemModel.fromJson(response.data['data']);
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
  Future<ImportUncheckedResponseModel> importUncheckedDataSource(List<String> codes, String userName) async {
    try {
      final requestData = codes.map((code) => {
        'zc_pull_qty_code': code,
        'zc_pull_qty_UserName': userName,
      }).toList();
      
      final response = await dio.post(
        ApiConstants.warehouseImportUncheckedUrl,
        data: requestData,
      );
      
      if (response.statusCode == 200) {
        return ImportUncheckedResponseModel.fromJson(response.data);
      } else {
        throw WarehouseException(StringKey.serverErrorMessage);
      }
    } on DioException catch (_) {
      throw WarehouseException(StringKey.networkErrorMessage);
    }
  }
}