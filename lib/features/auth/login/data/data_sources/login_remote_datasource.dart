import 'package:dio/dio.dart';
import 'package:warehouse_scan/core/constants/api_constants.dart';
import 'package:warehouse_scan/core/errors/server_exception.dart';
import 'package:warehouse_scan/core/services/get_translate_key.dart';
import '../../../../../core/errors/failures.dart';
import '../models/user_model.dart';

abstract class LoginRemoteDataSource {
  Future<UserModel> loginUser({
    required String userId,
    required String password,
    required String name,
  });
  
  Future<UserModel> validateToken(String token);
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final Dio dio;

  LoginRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> loginUser({
    required String userId,
    required String password,
    required String name,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.loginUrl,
        data: {
          'userID': userId,
          'password': password,
          'name': name,
        },
      );
      
      if (response.statusCode == 200) {
        if (response.data['message'] == '登錄成功') {
          return UserModel.fromJson(response.data);
        } else {
          throw AuthException(StringKey.invalidCredentialsMessage);
        }
      } else {
        throw AuthException(StringKey.invalidCredentialsMessage);
      }
    } on DioException catch (_) {
      throw ServerException(StringKey.serverErrorMessage);

    } catch(_){
      throw ConnectionFailure(StringKey.networkErrorMessage);
    }
  }
  
  @override
  Future<UserModel> validateToken(String token) async {
    throw UnimplementedError(StringKey.validateTokenMessage);
  }
}