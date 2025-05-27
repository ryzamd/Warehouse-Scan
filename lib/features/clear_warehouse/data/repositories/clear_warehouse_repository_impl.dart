import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import 'package:warehouse_scan/core/network/network_infor.dart';
import '../../../../core/services/get_translate_key.dart';
import '../../domain/entities/clear_warehouse_item_entity.dart';
import '../../domain/repositories/clear_warehouse_repository.dart';
import '../datasources/clear_warehouse_datasource.dart';

class ClearWarehouseRepositoryImpl implements ClearWarehouseRepository {
  final ClearWarehouseDataSource dataSource;
  final NetworkInfo networkInfo;

  ClearWarehouseRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ClearWarehouseItemEntity>> checkWarehouseItem(String code, String userName) async {
    if (await networkInfo.isConnected) {
      try {

        final result = await dataSource.checkWarehouseItem(code, userName);
        return Right(result);

      } on MaterialNotFoundException {
        return Left(ServerFailure(StringKey.materialNotFound));

      } on WarehouseException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure(StringKey.networkErrorMessage));
    }
  }

  @override
  Future<Either<Failure, bool>> clearWarehouseQuantity(String code, String userName) async {
    if (await networkInfo.isConnected) {
      try {

        final result = await dataSource.clearWarehouseQuantity(code, userName);
        return Right(result);
        
      } on WarehouseException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure(StringKey.networkErrorMessage));
    }
  }
}