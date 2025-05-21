import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:warehouse_scan/core/auth/auth_repository.dart';
import 'package:warehouse_scan/core/network/dio_client.dart';
import 'package:warehouse_scan/core/network/network_infor.dart';
import 'package:warehouse_scan/core/network/token_interceptor.dart';
import 'package:warehouse_scan/core/services/secure_storage_service.dart';
import 'package:warehouse_scan/features/auth/login/data/data_sources/login_remote_datasource.dart';
import 'package:warehouse_scan/features/auth/login/data/repositories/user_repository_impl.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
import 'package:warehouse_scan/features/auth/login/domain/repositories/user_repository.dart';
import 'package:warehouse_scan/features/auth/login/domain/usecases/user_login.dart';
import 'package:warehouse_scan/features/auth/login/domain/usecases/validate_token.dart';
import 'package:warehouse_scan/features/auth/login/presentation/bloc/login_bloc.dart';

import '../../features/address/data/datasource/address_datasource.dart';
import '../../features/address/data/repositories/address_repository_impl.dart';
import '../../features/address/domain/repositories/address_repository.dart';
import '../../features/address/domain/usecases/get_address_list_usecase.dart';
import '../../features/address/presentation/bloc/address_bloc.dart';
import '../../features/auth/logout/data/datasources/logout_datasource.dart';
import '../../features/auth/logout/data/repositories/logout_repository_impl.dart';
import '../../features/auth/logout/domain/repositories/logout_repository.dart';
import '../../features/auth/logout/domain/usecases/logout_usecase.dart';
import '../../features/auth/logout/presentation/bloc/logout_bloc.dart';
import '../../features/batch_scan/data/datasources/batch_scan_datasource.dart';
import '../../features/batch_scan/data/repositories/batch_scan_repository_impl.dart';
import '../../features/batch_scan/domain/repositories/batch_scan_repository.dart';
import '../../features/batch_scan/domain/usecases/check_batch_code.dart';
import '../../features/batch_scan/domain/usecases/process_batch.dart';
import '../../features/batch_scan/presentation/bloc/batch_scan_bloc.dart';
import '../../features/import_unchecked/data/datasources/import_unchecked_datasource.dart';
import '../../features/import_unchecked/data/repositories/import_unchecked_repository_impl.dart';
import '../../features/import_unchecked/domain/repositories/import_unchecked_repository.dart';
import '../../features/import_unchecked/domain/usecases/check_import_unchecked_code.dart';
import '../../features/import_unchecked/domain/usecases/import_unchecked_data.dart';
import '../../features/import_unchecked/presentation/bloc/import_unchecked_bloc.dart';
import '../../features/inventory_check/data/datasources/inventory_check_datasource.dart';
import '../../features/inventory_check/data/repositories/inventory_check_repository_impl.dart';
import '../../features/inventory_check/domain/repositories/inventory_check_repository.dart';
import '../../features/inventory_check/domain/usecases/check_item_code.dart';
import '../../features/inventory_check/domain/usecases/save_inventory_items.dart';
import '../../features/inventory_check/presentation/bloc/inventory_check_bloc.dart';
import '../../features/process/data/datasources/processing_remote_datasource.dart';
import '../../features/process/data/repositories/processing_repository_impl.dart';
import '../../features/process/domain/repositories/processing_repository.dart';
import '../../features/process/domain/usecases/get_processing_items.dart';
import '../../features/process/presentation/bloc/processing_bloc.dart';

import 'package:warehouse_scan/features/warehouse_scan/data/datasources/warehouse_in_datasource.dart';
import 'package:warehouse_scan/features/warehouse_scan/data/datasources/warehouse_out_datasource.dart';
import 'package:warehouse_scan/features/warehouse_scan/data/repositories/warehouse_in_repository_impl.dart';
import 'package:warehouse_scan/features/warehouse_scan/data/repositories/warehouse_out_repository_impl.dart';
import 'package:warehouse_scan/features/warehouse_scan/domain/repositories/warehouse_in_repository.dart';
import 'package:warehouse_scan/features/warehouse_scan/domain/repositories/warehouse_out_repository.dart';
import 'package:warehouse_scan/features/warehouse_scan/domain/usecases/get_material_info.dart';
import 'package:warehouse_scan/features/warehouse_scan/domain/usecases/process_warehouse_in.dart';
import 'package:warehouse_scan/features/warehouse_scan/domain/usecases/process_warehouse_out.dart';
import 'package:warehouse_scan/features/warehouse_scan/presentation/bloc/warehouse_in/warehouse_in_bloc.dart';
import 'package:warehouse_scan/features/warehouse_scan/presentation/bloc/warehouse_out/warehouse_out_bloc.dart';

import '../localization/language_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await _initSystemCore();
  await _initLoginFeature();
  await _initProcessFeature();
  await _initWarehousImportFeature();
  await _initWarehouseExportFeature();
  await _initCheckMaterialToImportInventory();
  await _initLogoutFeature();
  await _initBatchScanFeature();
  await _initAddressFeature();
  await _initImportUncheckedFeature();
}

Future<void> _initSystemCore() async {
  
  sl.registerLazySingleton(() => SecureStorageService());
  
  final dioClient = DioClient();
  sl.registerLazySingleton<DioClient>(() => dioClient);
  
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(sl<SecureStorageService>(), sl<DioClient>()));
  
  final navigatorKey = GlobalKey<NavigatorState>();
  sl.registerLazySingleton<GlobalKey<NavigatorState>>(() => navigatorKey);
  
  final tokenInterceptor = TokenInterceptor(
    authRepository: sl<AuthRepository>(),
    navigatorKey: sl<GlobalKey<NavigatorState>>(),
  );
  
  dioClient.dio.interceptors.insert(0, tokenInterceptor);
  
  sl.registerLazySingleton<Dio>(() => dioClient.dio);

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  sl.registerLazySingleton(() => LanguageBloc(sharedPreferences: sl()));
}

Future<void> _initLoginFeature() async {
  sl.registerFactory(
    () => LoginBloc(
      userLogin: sl(),
      validateToken: sl(),
    ),
  );

  sl.registerLazySingleton(() => UserLogin(sl()));
  sl.registerLazySingleton(() => ValidateToken(sl()));

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<LoginRemoteDataSource>(
    () => LoginRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance(
    checkTimeout: const Duration(milliseconds: 800),
    checkInterval: const Duration(seconds: 10),
  ));
}

Future<void> _initProcessFeature() async {

  sl.registerFactory(() => ProcessingBloc(getProcessingItems: sl()));

  sl.registerLazySingleton(() => GetProcessingItems(sl()));

  sl.registerLazySingleton<ProcessingRepository>(
    () => ProcessingRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ProcessingRemoteDataSource>(
    () => ProcessingRemoteDataSourceImpl(
      dio: sl(),
      useMockData: false
    ),
  );
}

Future<void> _initWarehousImportFeature() async {
  
  sl.registerLazySingleton<WarehouseInDataSource>(
    () => WarehouseInDataSourceImpl(dio: sl()),
  );
  
  sl.registerLazySingleton<WarehouseInRepository>(
    () => WarehouseInRepositoryImpl(
      dataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  sl.registerLazySingleton(() => ProcessWarehouseIn(sl()));

  sl.registerFactoryParam<WarehouseInBloc, UserEntity, void>(
    (user, _) => WarehouseInBloc(
      processWarehouseIn: sl(),
      connectionChecker: sl(),
      currentUser: user,
    ),
  );
}

Future<void> _initWarehouseExportFeature() async {
  
  sl.registerLazySingleton<WarehouseOutDataSource>(
    () => WarehouseOutDataSourceImpl(dio: sl()),
  );
  
  sl.registerLazySingleton<WarehouseOutRepository>(
    () => WarehouseOutRepositoryImpl(
      dataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  sl.registerLazySingleton(() => GetMaterialInfo(sl()));
  sl.registerLazySingleton(() => ProcessWarehouseOut(sl()));
  
  sl.registerFactoryParam<WarehouseOutBloc, UserEntity, void>(
    (user, _) => WarehouseOutBloc(
      getMaterialInfo: sl(),
      processWarehouseOut: sl(),
      connectionChecker: sl(),
      currentUser: user,
    ),
  );
}

Future<void> _initLogoutFeature() async {

  sl.registerLazySingleton<LogoutDataSource>(
    () => LogoutDataSourceImpl(
      sharedPreferences: sl(),
      dioClient: sl(),
    ),
  );

  sl.registerLazySingleton<LogoutRepository>(() => LogoutRepositoryImpl(dataSource: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  sl.registerFactory(
    () => LogoutBloc(
      logoutUseCase: sl(),
    ),
  );
}

Future<void> _initCheckMaterialToImportInventory() async {

  sl.registerLazySingleton<InventoryCheckDataSource>(() => InventoryCheckDataSourceImpl(dio: sl()));
  
  sl.registerLazySingleton<InventoryCheckRepository>(
    () => InventoryCheckRepositoryImpl(
      dataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  sl.registerLazySingleton(() => CheckItemCode(sl()));
  sl.registerLazySingleton(() => SaveInventoryItems(sl()));
  
  sl.registerFactoryParam<InventoryCheckBloc, UserEntity, void>(
    (user, _) => InventoryCheckBloc(
      checkItemCode: sl(),
      saveInventoryItems: sl(),
      connectionChecker: sl(),
      currentUser: user,
    ),
  );
}

Future<void> _initBatchScanFeature() async {
  sl.registerLazySingleton<BatchScanDataSource>(
    () => BatchScanDataSourceImpl(dio: sl()),
  );
  
  sl.registerLazySingleton<BatchScanRepository>(
    () => BatchScanRepositoryImpl(
      dataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  sl.registerLazySingleton(() => CheckBatchCode(sl()));
  sl.registerLazySingleton(() => ProcessBatch(sl()));
  
  sl.registerFactoryParam<BatchScanBloc, UserEntity, void>(
    (user, _) => BatchScanBloc(
      checkBatchCode: sl(),
      processBatch: sl(),
      connectionChecker: sl(),
      currentUser: user,
    ),
  );
}

Future<void> _initAddressFeature() async {
  sl.registerLazySingleton<AddressDataSource>(() => AddressDataSourceImpl(dio: sl()));
  
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(
      dataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  sl.registerLazySingleton(() => GetAddressListUseCase(sl()));
  
  sl.registerFactory(() => AddressBloc(getAddressListUseCase: sl()));
}

Future<void> _initImportUncheckedFeature() async {
  sl.registerLazySingleton<ImportUncheckedDataSource>(
    () => ImportUncheckedDataSourceImpl(dio: sl()),
  );
  
  sl.registerLazySingleton<ImportUncheckedRepository>(
    () => ImportUncheckedRepositoryImpl(
      dataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  sl.registerLazySingleton(() => CheckImportUncheckedCode(sl()));
  sl.registerLazySingleton(() => ImportUncheckedData(sl()));
  
  sl.registerFactoryParam<ImportUncheckedBloc, UserEntity, void>(
    (user, _) => ImportUncheckedBloc(
      checkImportUncheckedCode: sl(),
      importUncheckedData: sl(),
      connectionChecker: sl(),
      currentUser: user,
    ),
  );
}