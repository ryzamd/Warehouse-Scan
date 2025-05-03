import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import 'package:warehouse_scan/core/network/network_infor.dart';
import 'package:warehouse_scan/core/services/get_translate_key.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasource/address_datasource.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressDataSource dataSource;
  final NetworkInfo networkInfo;

  AddressRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AddressEntity>> getAddressList() async {
    if (await networkInfo.isConnected) {
      try {

        final addresses = await dataSource.getAddressList();
        return Right(addresses);

      } on WarehouseException catch (_) {
        return Left(ServerFailure(StringKey.getAddressListFailedMessage));

      }
    } else {
      return Left(ConnectionFailure(StringKey.networkErrorMessage));
    }
  }
}