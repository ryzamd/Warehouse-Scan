import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/inventory_item_entity.dart';
import '../repositories/inventory_check_repository.dart';

class SaveInventoryItems {
  final InventoryCheckRepository repository;

  SaveInventoryItems(this.repository);

  Future<Either<Failure, List<InventoryItemEntity>>> call(SaveInventoryItemsParams params) async {
    return await repository.saveInventoryItems(params.codes);
  }
}

class SaveInventoryItemsParams extends Equatable {
  final List<String> codes;

  const SaveInventoryItemsParams({required this.codes});

  @override
  List<Object> get props => [codes];
}