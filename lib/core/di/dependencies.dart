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
import 'package:warehouse_scan/features/auth/login/domain/repositories/user_repository.dart';
import 'package:warehouse_scan/features/auth/login/domain/usecases/user_login.dart';
import 'package:warehouse_scan/features/auth/login/domain/usecases/validate_token.dart';
import 'package:warehouse_scan/features/auth/login/presentation/bloc/login_bloc.dart';

import '../../features/process/data/datasources/processing_remote_datasource.dart';
import '../../features/process/data/repositories/processing_repository_impl.dart';
import '../../features/process/domain/repositories/processing_repository.dart';
import '../../features/process/domain/usecases/get_processing_items.dart';
import '../../features/process/presentation/bloc/processing_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core services
  sl.registerLazySingleton(() => SecureStorageService());
  
  // Create DioClient instance
  final dioClient = DioClient();
  sl.registerLazySingleton<DioClient>(() => dioClient);
  
  // Register AuthRepository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl<SecureStorageService>(), sl<DioClient>()),
  );
  
  // Register navigator key
  final navigatorKey = GlobalKey<NavigatorState>();
  sl.registerLazySingleton<GlobalKey<NavigatorState>>(() => navigatorKey);
  
  // Create TokenInterceptor and add it to DioClient immediately
  final tokenInterceptor = TokenInterceptor(
    authRepository: sl<AuthRepository>(),
    navigatorKey: sl<GlobalKey<NavigatorState>>(),
  );
  
  // Add interceptor to dio client
  dioClient.dio.interceptors.insert(0, tokenInterceptor);
  
  // Register the individual Dio instance
  sl.registerLazySingleton<Dio>(() => dioClient.dio);
  
  // ======= Login Page ======== //
  // BLoC
  sl.registerFactory(
    () => LoginBloc(
      userLogin: sl(),
      validateToken: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => UserLogin(sl()));
  sl.registerLazySingleton(() => ValidateToken(sl()));

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<LoginRemoteDataSource>(
    () => LoginRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => InternetConnectionChecker());

  // ======= End Login Page ======== //

  // ======= Process Page ======== //
  // BLoC
  sl.registerFactory(
    () => ProcessingBloc(
      getProcessingItems: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProcessingItems(sl()));

  // Repository
  sl.registerLazySingleton<ProcessingRepository>(
    () => ProcessingRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProcessingRemoteDataSource>(
    () => ProcessingRemoteDataSourceImpl(dio: sl(), useMockData: false),
  );

  // ======= End Process Page ======== //
}