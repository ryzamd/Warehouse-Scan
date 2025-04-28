import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/batch_item_entity.dart';
import '../entities/batch_process_response_entity.dart';

abstract class BatchScanRepository {
  Future<Either<Failure, BatchItemEntity>> checkCode(String code, String userName);

  Future<Either<Failure, BatchProcessResponseEntity>> processBatch({
    required List<String> codes,
    required String userName,
    required String address,
    required double quantity,
    required int operationMode,
  });
}