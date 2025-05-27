import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../repositories/clear_warehouse_repository.dart';

class ClearWarehouseQuantity {
  final ClearWarehouseRepository repository;

  ClearWarehouseQuantity(this.repository);

  Future<Either<Failure, bool>> call(ClearWarehouseQuantityParams params) async {
    return await repository.clearWarehouseQuantity(params.code, params.userName);
  }
}

class ClearWarehouseQuantityParams extends Equatable {
  final String code;
  final String userName;

  const ClearWarehouseQuantityParams({
    required this.code,
    required this.userName,
  });

  @override
  List<Object> get props => [code, userName];
}