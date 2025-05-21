import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/import_unchecked_item_entity.dart';
import '../entities/import_unchecked_response_entity.dart';

abstract class ImportUncheckedRepository {
  Future<Either<Failure, ImportUncheckedItemEntity>> checkItemCode(String code, String userName);
  
  Future<Either<Failure, ImportUncheckedResponseEntity>> importUncheckedData(List<String> codes, String userName);
}