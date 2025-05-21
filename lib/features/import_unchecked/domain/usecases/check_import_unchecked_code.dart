import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/import_unchecked_item_entity.dart';
import '../repositories/import_unchecked_repository.dart';

class CheckImportUncheckedCode {
  final ImportUncheckedRepository repository;

  CheckImportUncheckedCode(this.repository);

  Future<Either<Failure, ImportUncheckedItemEntity>> call(CheckImportUncheckedCodeParams params) async {
    return await repository.checkItemCode(params.code, params.userName);
  }
}

class CheckImportUncheckedCodeParams extends Equatable {
  final String code;
  final String userName;

  const CheckImportUncheckedCodeParams({
    required this.code,
    required this.userName,
  });

  @override
  List<Object> get props => [code, userName];
}