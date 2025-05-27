import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/clear_warehouse_item_entity.dart';
import '../repositories/clear_warehouse_repository.dart';

class CheckWarehouseItem {
  final ClearWarehouseRepository repository;

  CheckWarehouseItem(this.repository);

  Future<Either<Failure, ClearWarehouseItemEntity>> call(CheckWarehouseItemParams params) async {
    return await repository.checkWarehouseItem(params.code, params.userName);
  }
}

class CheckWarehouseItemParams extends Equatable {
  final String code;
  final String userName;

  const CheckWarehouseItemParams({
    required this.code,
    required this.userName,
  });

  @override
  List<Object> get props => [code, userName];
}