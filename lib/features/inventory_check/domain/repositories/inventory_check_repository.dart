import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/inventory_item_entity.dart';

abstract class InventoryCheckRepository {
  Future<Either<Failure, InventoryItemEntity>> checkItemCode(String code, String userName);

  Future<Either<Failure, List<InventoryItemEntity>>> saveInventoryItems(List<String> codes);
}