import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import 'package:warehouse_scan/features/process/domain/entities/processing_item_entity.dart';

abstract class ProcessingRepository {
  /// Get all processing items from remote source with userName
  ///
  /// Returns list of [ProcessingItemEntity] if successful, [Failure] otherwise
  Future<Either<Failure, List<ProcessingItemEntity>>> getProcessingItems(String date);
}