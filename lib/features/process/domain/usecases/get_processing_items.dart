import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import 'package:warehouse_scan/features/process/domain/entities/processing_item_entity.dart';
import 'package:warehouse_scan/features/process/domain/repositories/processing_repository.dart';

class GetProcessingItems {
  final ProcessingRepository repository;

  GetProcessingItems(this.repository);

  /// Execute the get processing items use case
  Future<Either<Failure, List<ProcessingItemEntity>>> call(GetProcessingParams params) async {
    return await repository.getProcessingItems(params.date);
  }
}

class GetProcessingParams extends Equatable {
  final String date;

  const GetProcessingParams({required this.date});
  
  @override
  List<Object> get props => [date];
}