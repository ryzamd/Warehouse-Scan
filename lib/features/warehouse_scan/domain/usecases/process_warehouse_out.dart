// lib/features/warehouse_scan/domain/usecases/process_warehouse_out.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../repositories/warehouse_out_repository.dart';

class ProcessWarehouseOut {
  final WarehouseOutRepository repository;

  ProcessWarehouseOut(this.repository);

  Future<Either<Failure, bool>> call(ProcessWarehouseOutParams params) async {
    return await repository.processWarehouseOut(
      code: params.code,
      userName: params.userName,
      address: params.address,
      quantity: params.quantity,
    );
  }
}

class ProcessWarehouseOutParams extends Equatable {
  final String code;
  final String userName;
  final String address;
  final double quantity;

  const ProcessWarehouseOutParams({
    required this.code,
    required this.userName,
    required this.address,
    required this.quantity,
  });

  @override
  List<Object> get props => [code, userName, address, quantity];
}