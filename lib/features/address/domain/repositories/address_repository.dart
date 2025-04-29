import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/address_entity.dart';

abstract class AddressRepository {
  Future<Either<Failure, AddressEntity>> getAddressList();
}