import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/server_exception.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import 'package:warehouse_scan/core/network/network_infor.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../data_sources/login_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final LoginRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> loginUser({
    required String userId,
    required String password,
    required String name,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.loginUser(
          userId: userId,
          password: password,
          name: name,
        );
        
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(ConnectionFailure('No internet connection. Please check your network settings and try again.'));
    }
  }
  
  @override
  Future<Either<Failure, UserEntity>> validateToken(String token) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.validateToken(token);
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(ConnectionFailure('No internet connection. Please check your network settings and try again.'));
    }
  }
}