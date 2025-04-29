import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import 'package:warehouse_scan/core/errors/warehouse_exceptions.dart';
import 'package:warehouse_scan/core/network/network_infor.dart';
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
      } on WarehouseException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(ConnectionFailure('No internet connection. Please check your network settings and try again.'));
    }
  }
}