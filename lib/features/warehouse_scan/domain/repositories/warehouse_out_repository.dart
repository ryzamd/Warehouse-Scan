// lib/features/warehouse_scan/domain/repositories/warehouse_out_repository.dart
import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/warehouse_out_entity.dart';

abstract class WarehouseOutRepository {
  /// Get material information based on scanned code
  ///
  /// Returns [WarehouseOutEntity] with material data or [Failure]
  Future<Either<Failure, WarehouseOutEntity>> getMaterialInfo(String code, String userName);
  
  /// Process warehouse out data
  ///
  /// Returns [bool] indicating success or [Failure]
  Future<Either<Failure, bool>> processWarehouseOut({
    required String code,
    required String address,
    required double quantity,
    required String userName,
  });
}