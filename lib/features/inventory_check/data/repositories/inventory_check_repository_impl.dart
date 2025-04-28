import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import 'package:warehouse_scan/core/network/network_infor.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../domain/repositories/inventory_check_repository.dart';
import '../datasources/inventory_check_datasource.dart';

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
        return Left(ServerFailure('Material is not exist in system.'));

      } on WarehouseException catch (e) {
        return Left(ServerFailure(e.message));

      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(ConnectionFailure('No internet access, please check internet connection.'));
    }
  }
  
  @override
  Future<Either<Failure, List<InventoryItemEntity>>> saveInventoryItems(List<String> codes) async {
    if (await networkInfo.isConnected) {
      try {
        final items = await dataSource.saveInventoryItems(codes);
        return Right(items);

      } on WarehouseException catch (e) {
        return Left(ServerFailure(e.message));

      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(ConnectionFailure('No internet access, please check internet connection.'));
    }
  }
}