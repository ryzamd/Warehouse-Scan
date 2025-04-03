import 'package:dartz/dartz.dart';
import 'package:warehouse_scan/core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  /// Authenticates a user with the given credentials
  ///
  /// Returns [UserEntity] if successful, [Failure] otherwise
  Future<Either<Failure, UserEntity>> loginUser({
    required String userId,
    required String password,
    required String name,
  });
  
  /// Validates a JWT token
  ///
  /// Returns [UserEntity] if token is valid, [Failure] otherwise
  Future<Either<Failure, UserEntity>> validateToken(String token);
}