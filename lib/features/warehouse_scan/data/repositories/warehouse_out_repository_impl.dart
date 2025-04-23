// lib/features/warehouse_scan/data/repositories/warehouse_out_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import 'package:warehouse_scan/core/network/network_infor.dart';
import 'package:warehouse_scan/features/warehouse_scan/domain/entities/get_address_list_entity.dart';
import '../../domain/entities/warehouse_out_entity.dart';
import '../../domain/repositories/warehouse_out_repository.dart';
import '../datasources/warehouse_out_datasource.dart';

class WarehouseOutRepositoryImpl implements WarehouseOutRepository {
  final WarehouseOutDataSource dataSource;
  final NetworkInfo networkInfo;

  WarehouseOutRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, WarehouseOutEntity>> getMaterialInfo(String code, String userName) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await dataSource.getMaterialInfo(code, userName);
        return Right(result);
      } on MaterialNotFoundException {
        return Left(ServerFailure('Material with code $code not found in the system.'));
      } on WarehouseOutException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(ConnectionFailure('No internet connection. Please check your network settings and try again.'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> processWarehouseOut({
    required String code,
    required String address,
    required double quantity,
    required String userName,
    required int optionFunction,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await dataSource.processWarehouseOut(
          code: code,
          address: address,
          quantity: quantity,
          userName: userName,
          optionFunction: optionFunction,
        );
        return Right(result);
      } on WarehouseOutException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No internet connection. Please check your network settings and try again.'));
    }
  }

  @override
  Future<Either<Failure, GetAddressListEntity>> getAddressList() async {

    if(!await networkInfo.isConnected){
      return Left(ConnectionFailure('No internet connection. Please check your network settings and try again.'));
    }

    try {

      final result = await dataSource.getAddressList();

      return Right(result);

    } on WarehouseOutException catch (e) {

      return Left(ServerFailure(e.message));
    }
  }
}