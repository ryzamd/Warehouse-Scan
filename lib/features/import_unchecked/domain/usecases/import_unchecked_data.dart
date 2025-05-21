import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/import_unchecked_response_entity.dart';
import '../repositories/import_unchecked_repository.dart';

class ImportUncheckedData {
  final ImportUncheckedRepository repository;

  ImportUncheckedData(this.repository);

  Future<Either<Failure, ImportUncheckedResponseEntity>> call(ImportUncheckedDataParams params) async {
    return await repository.importUncheckedData(params.codes, params.userName);
  }
}

class ImportUncheckedDataParams extends Equatable {
  final List<String> codes;
  final String userName;

  const ImportUncheckedDataParams({
    required this.codes,
    required this.userName,
  });

  @override
  List<Object> get props => [codes, userName];
}