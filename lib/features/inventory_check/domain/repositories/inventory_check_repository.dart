import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/inventory_item_entity.dart';
import '../../data/models/batch_inventory_response_model.dart';

abstract class InventoryCheckRepository {
  Future<Either<Failure, InventoryItemEntity>> checkItemCode(String code, String userName);
  
  Future<Either<Failure, BatchInventoryResponseModel>> saveInventoryItems(List<String> codes);
}