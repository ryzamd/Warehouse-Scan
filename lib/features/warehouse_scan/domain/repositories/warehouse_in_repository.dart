// lib/features/warehouse_scan/domain/repositories/warehouse_in_repository.dart
import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/warehouse_in_entity.dart';

abstract class WarehouseInRepository {
  /// Send scan data to server for warehouse in process
  ///
  /// Returns [WarehouseInEntity] with success data or [Failure]
  Future<Either<Failure, WarehouseInEntity>> processWarehouseIn(String code, String userName);
}