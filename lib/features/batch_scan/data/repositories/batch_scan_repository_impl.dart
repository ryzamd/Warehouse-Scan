import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import 'package:warehouse_scan/core/network/network_infor.dart';

import '../../../../core/services/get_translate_key.dart';
import '../../domain/entities/batch_item_entity.dart';
import '../../domain/entities/batch_process_response_entity.dart';
import '../../domain/repositories/batch_scan_repository.dart';
import '../datasources/batch_scan_datasource.dart';

class BatchScanRepositoryImpl implements BatchScanRepository {
  final BatchScanDataSource dataSource;
  final NetworkInfo networkInfo;

  BatchScanRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, BatchItemEntity>> checkCode(String code, String userName) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await dataSource.checkCode(code, userName);
        return Right(result);
      } on MaterialNotFoundException {
        return Left(ServerFailure(StringKey.materialWithCodeNotFoundMessage));
      }
    } else {
      return Left(ConnectionFailure(StringKey.networkErrorMessage));
    }
  }

  @override
  Future<Either<Failure, BatchProcessResponseEntity>> processBatch({
    required List<String> codes,
    required String userName,
    required String address,
    required double quantity,
    required int operationMode,
  }) async {
    if (await networkInfo.isConnected) {

      try {
        final result = await dataSource.processBatch(
          codes: codes,
          userName: userName,
          address: address,
          quantity: quantity,
          operationMode: operationMode,
        );
        return Right(result);

      } on WarehouseException catch (_) {
        return Left(ServerFailure(StringKey.somethingWentWrongMessage));
      }
    } else {
      return Left(ConnectionFailure(StringKey.networkErrorMessage));
    }
  }
}