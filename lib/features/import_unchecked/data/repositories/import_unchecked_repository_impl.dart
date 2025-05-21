// lib/features/import_unchecked/data/repositories/import_unchecked_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import 'package:warehouse_scan/core/network/network_infor.dart';
import '../../../../core/services/get_translate_key.dart';
import '../../domain/entities/import_unchecked_item_entity.dart';
import '../../domain/entities/import_unchecked_response_entity.dart';
import '../../domain/repositories/import_unchecked_repository.dart';
import '../datasources/import_unchecked_datasource.dart';

class ImportUncheckedRepositoryImpl implements ImportUncheckedRepository {
  final ImportUncheckedDataSource dataSource;
  final NetworkInfo networkInfo;

  ImportUncheckedRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ImportUncheckedItemEntity>> checkItemCode(String code, String userName) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await dataSource.checkItemCodeDataSource(code, userName);
        return Right(result);
      } on MaterialNotFoundException {
        return Left(ServerFailure(StringKey.materialNotFound));
      }
    } else {
      return Left(ConnectionFailure(StringKey.networkErrorMessage));
    }
  }

  @override
  Future<Either<Failure, ImportUncheckedResponseEntity>> importUncheckedData(List<String> codes, String userName) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await dataSource.importUncheckedDataSource(codes, userName);
        return Right(result);
      } on WarehouseException catch (_) {
        return Left(ServerFailure(StringKey.somethingWentWrongMessage));
      }
    } else {
      return Left(ConnectionFailure(StringKey.networkErrorMessage));
    }
  }
}