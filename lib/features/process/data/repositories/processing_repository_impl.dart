import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import 'package:warehouse_scan/core/errors/server_exception.dart';
import 'package:warehouse_scan/core/network/network_infor.dart';
import 'package:warehouse_scan/features/process/data/datasources/processing_remote_datasource.dart';
import 'package:warehouse_scan/features/process/domain/entities/processing_item_entity.dart';
import 'package:warehouse_scan/features/process/domain/repositories/processing_repository.dart';

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
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(ConnectionFailure('No internet connection. Please check your network settings and try again.'));
    }
  }
}