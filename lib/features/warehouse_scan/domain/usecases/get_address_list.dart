
import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/features/warehouse_scan/domain/entities/get_address_list_entity.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/warehouse_out_repository.dart';

class GetAddressList {
  final WarehouseOutRepository repository;

  GetAddressList(this.repository);

  Future<Either<Failure, GetAddressListEntity>> call() async {
    return await repository.getAddressList();
  }
}