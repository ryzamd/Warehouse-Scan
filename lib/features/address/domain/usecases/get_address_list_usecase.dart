import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/address_entity.dart';
import '../repositories/address_repository.dart';

class GetAddressListUseCase {
  final AddressRepository repository;

  GetAddressListUseCase(this.repository);

  Future<Either<Failure, AddressEntity>> call() async {
    return await repository.getAddressList();
  }
}