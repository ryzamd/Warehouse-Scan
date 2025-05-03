import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import 'package:warehouse_scan/core/network/network_infor.dart';
import '../../../../core/services/get_translate_key.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../domain/repositories/inventory_check_repository.dart';
import '../datasources/inventory_check_datasource.dart';
import '../models/batch_inventory_response_model.dart';

class InventoryCheckRepositoryImpl implements InventoryCheckRepository {
  final InventoryCheckDataSource dataSource;
  final NetworkInfo networkInfo;

  InventoryCheckRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, InventoryItemEntity>> checkItemCode(String code, String userName) async {
    if (await networkInfo.isConnected) {
      try {

        final item = await dataSource.checkItemCode(code, userName);

        return Right(item);

      } on MaterialNotFoundException {
        return Left(ServerFailure(StringKey.materialNotFound));
      }
    } else {
      return Left(ConnectionFailure(StringKey.networkErrorMessage));
    }
  }
  
  @override
  Future<Either<Failure, BatchInventoryResponseModel>> saveInventoryItems(List<String> codes) async {
    if (await networkInfo.isConnected) {
      try {

        final response = await dataSource.saveInventoryItems(codes);

        return Right(response);

      } on WarehouseException catch (_) {
        return Left(ServerFailure(StringKey.cannotSavingInventoryListMessage));

      }
    } else {
      return Left(ConnectionFailure(StringKey.networkErrorMessage));
    }
  }
}