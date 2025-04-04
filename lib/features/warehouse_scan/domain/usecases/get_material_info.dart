// lib/features/warehouse_scan/domain/usecases/get_material_info.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/warehouse_out_entity.dart';
import '../repositories/warehouse_out_repository.dart';

class GetMaterialInfo {
  final WarehouseOutRepository repository;

  GetMaterialInfo(this.repository);

  Future<Either<Failure, WarehouseOutEntity>> call(GetMaterialInfoParams params) async {
    return await repository.getMaterialInfo(params.code, params.userName);
  }
}

class GetMaterialInfoParams extends Equatable {
  final String code;
  final String userName;

  const GetMaterialInfoParams({
    required this.code,
    required this.userName,
  });

  @override
  List<Object> get props => [code, userName];
}