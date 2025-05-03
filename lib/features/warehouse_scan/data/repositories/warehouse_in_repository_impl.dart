// lib/features/warehouse_scan/data/repositories/warehouse_in_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import 'package:warehouse_scan/core/network/network_infor.dart';
import '../../../../core/services/get_translate_key.dart';
import '../../domain/entities/warehouse_in_entity.dart';
import '../../domain/repositories/warehouse_in_repository.dart';
import '../datasources/warehouse_in_datasource.dart';

class WarehouseInRepositoryImpl implements WarehouseInRepository {
  final WarehouseInDataSource dataSource;
  final NetworkInfo networkInfo;

  WarehouseInRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, WarehouseInEntity>> processWarehouseIn(String code, String userName) async {
    if (await networkInfo.isConnected) {
      try {

        final result = await dataSource.processWarehouseIn(code, userName);
        return Right(result);

      } on WarehouseInException catch (_) {
        return Left(ServerFailure(StringKey.materialNotFound));
      }
    } else {
      return Left(ConnectionFailure(StringKey.networkErrorMessage));
    }
  }
}