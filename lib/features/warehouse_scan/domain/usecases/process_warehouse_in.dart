// lib/features/warehouse_scan/domain/usecases/process_warehouse_in.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/warehouse_in_entity.dart';
import '../repositories/warehouse_in_repository.dart';

class ProcessWarehouseIn {
  final WarehouseInRepository repository;

  ProcessWarehouseIn(this.repository);

  Future<Either<Failure, WarehouseInEntity>> call(ProcessWarehouseInParams params) async {
    return await repository.processWarehouseIn(params.code, params.userName);
  }
}

class ProcessWarehouseInParams extends Equatable {
  final String code;
  final String userName;

  const ProcessWarehouseInParams({
    required this.code,
    required this.userName,
  });

  @override
  List<Object> get props => [code, userName];
}