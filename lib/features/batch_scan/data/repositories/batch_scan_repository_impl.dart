import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import 'package:warehouse_scan/core/network/network_infor.dart';

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
        return Left(ServerFailure('Material with code $code not found in the system.'));
      } on WarehouseException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(ConnectionFailure('No internet connection. Please check your network settings and try again.'));
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
      } on WarehouseException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(ConnectionFailure('No internet connection. Please check your network settings and try again.'));
    }
  }
}