import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/inventory_item_entity.dart';
import '../repositories/inventory_check_repository.dart';

class CheckItemCode {
  final InventoryCheckRepository repository;

  CheckItemCode(this.repository);

  Future<Either<Failure, InventoryItemEntity>> call(CheckItemCodeParams params) async {
    return await repository.checkItemCode(params.code, params.userName);
  }
}

class CheckItemCodeParams extends Equatable {
  final String code;
  final String userName;

  const CheckItemCodeParams({required this.code, required this.userName});

  @override
  List<Object> get props => [code, userName];
}