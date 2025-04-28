import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/batch_item_entity.dart';
import '../repositories/batch_scan_repository.dart';

class CheckBatchCode {
  final BatchScanRepository repository;

  CheckBatchCode(this.repository);

  Future<Either<Failure, BatchItemEntity>> call(CheckBatchCodeParams params) async {
    return await repository.checkCode(params.code, params.userName);
  }
}

class CheckBatchCodeParams extends Equatable {
  final String code;
  final String userName;

  const CheckBatchCodeParams({
    required this.code,
    required this.userName,
  });

  @override
  List<Object> get props => [code, userName];
}