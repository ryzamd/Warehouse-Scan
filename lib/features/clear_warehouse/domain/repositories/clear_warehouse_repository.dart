import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/clear_warehouse_item_entity.dart';

abstract class ClearWarehouseRepository {
  Future<Either<Failure, ClearWarehouseItemEntity>> checkWarehouseItem(String code, String userName);
  
  Future<Either<Failure, bool>> clearWarehouseQuantity(String code, String userName);
}