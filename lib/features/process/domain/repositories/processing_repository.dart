import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import 'package:warehouse_scan/features/process/domain/entities/processing_item_entity.dart';

abstract class ProcessingRepository {
  Future<Either<Failure, List<ProcessingItemEntity>>> getProcessingItems(String date);
}