import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import 'package:warehouse_scan/core/errors/server_exception.dart';
import 'package:warehouse_scan/core/network/network_infor.dart';
import 'package:warehouse_scan/features/process/data/datasources/processing_remote_datasource.dart';
import 'package:warehouse_scan/features/process/domain/entities/processing_item_entity.dart';
import 'package:warehouse_scan/features/process/domain/repositories/processing_repository.dart';

import '../../../../core/services/get_translate_key.dart';

class ProcessingRepositoryImpl implements ProcessingRepository {
  final ProcessingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProcessingRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ProcessingItemEntity>>> getProcessingItems(String date) async {
    if (await networkInfo.isConnected) {
      try {

        final processingItems = await remoteDataSource.getProcessingItems(date);
        return Right(processingItems);

      } on ServerException catch (_) {
        return Left(ServerFailure(StringKey.cannotGetProcessingItemsMessage));
      }
    } else {
      return Left(ConnectionFailure(StringKey.networkErrorMessage));
    }
  }
}