import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/warehouse_out_entity.dart';

abstract class WarehouseOutRepository {

  Future<Either<Failure, WarehouseOutEntity>> getMaterialInfo(String code, String userName);

  Future<Either<Failure, bool>> processWarehouseOut({
    required String code,
    required String address,
    required double quantity,
    required String userName,
    required int optionFunction,
  });
}