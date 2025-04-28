import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/batch_process_response_entity.dart';
import '../repositories/batch_scan_repository.dart';

class ProcessBatch {
  final BatchScanRepository repository;

  ProcessBatch(this.repository);

  Future<Either<Failure, BatchProcessResponseEntity>> call(ProcessBatchParams params) async {
    return await repository.processBatch(
      codes: params.codes,
      userName: params.userName,
      address: params.address,
      quantity: params.quantity,
      operationMode: params.operationMode,
    );
  }
}

class ProcessBatchParams extends Equatable {
  final List<String> codes;
  final String userName;
  final String address;
  final double quantity;
  final int operationMode;

  const ProcessBatchParams({
    required this.codes,
    required this.userName,
    required this.address,
    required this.quantity,
    required this.operationMode,
  });

  @override
  List<Object> get props => [codes, userName, address, quantity, operationMode];
}