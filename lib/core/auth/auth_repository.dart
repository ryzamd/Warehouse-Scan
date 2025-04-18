// lib/core/repositories/auth_repository.dart
import 'dart:convert';
import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../features/auth/login/data/models/user_model.dart';
import '../../features/auth/login/domain/entities/user_entity.dart';
import '../constants/api_constants.dart';
import '../errors/failures.dart';
import '../network/dio_client.dart';
import '../services/secure_storage_service.dart';


class AuthRepository {
  final SecureStorageService _secureStorage;
  final DioClient _dioClient;

  AuthRepository(this._secureStorage, this._dioClient);

  // Login user and save token
  Future<Either<Failure, UserEntity>> loginUser({
    required String userId,
    required String password,
    required String name,
  }) async {

     final authDio = Dio()
    ..options.baseUrl = _dioClient.dio.options.baseUrl
    ..options.connectTimeout = _dioClient.dio.options.connectTimeout
    ..options.receiveTimeout = _dioClient.dio.options.receiveTimeout;
    
    try {
      final response = await authDio.post(
        ApiConstants.loginUrl,
        data: {
          'userID': userId,
          'password': password,
          'name': name,
        },
      );
      
      if (response.statusCode == 200) {
        if (response.data['message'] == '登錄成功') {
          final user = UserModel.fromJson(response.data);
          final token = response.data['token'];
          
          // Ensure token isn't null or empty
          if (token == null || token.isEmpty) {
            return Left(AuthFailure('No token received from server'));
          }
          
          // Save token to secure storage
          await _secureStorage.saveAccessTokenAsync(token);
          await _secureStorage.saveUserIdAsync(user.userId);
          
          // Save user data
          await _secureStorage.saveUserDataAsync(jsonEncode(response.data['user']['users']));
          
          // Explicitly set token in DioClient for immediate use
          _dioClient.setAuthToken(token);
          
          debugPrint('Login successful, token saved and set in DioClient');
          return Right(user);
        } else {
          return Left(AuthFailure(response.data['message'] ?? 'Invalid credentials'));
        }
      } else {
        return Left(AuthFailure('Server returned ${response.statusCode}'));
      }
    } on DioException catch (e) {
      debugPrint('DioException in loginUser: ${e.message}');
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      debugPrint('Unexpected error in loginUser: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  // Check if token is valid (not expired)
  Future<bool> isTokenValid() async {
    final token = await _secureStorage.getAccessTokenAsync();
    if (token == null || token.isEmpty) {
      return false;
    }

    // Check expiry if available
    final expiry = await _secureStorage.getTokenExpiryAsync();
    if (expiry != null) {
      return expiry.isAfter(DateTime.now());
    }
    
    // If no expiry info, assume token is valid
    return true;
  }

  // Logout user and clear all data
  Future<bool> logout() async {
    try {
      await _secureStorage.clearAllDataAsync();
      _dioClient.clearAuthToken();
      return true;
    } catch (e) {
      debugPrint('Error during logout: $e');
      return false;
    }
  }

  // Get current access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.getAccessTokenAsync();
  }

  // Check if user is logged in with valid token
  Future<bool> isLoggedIn() async {
    return await _secureStorage.hasTokenAsync() && await isTokenValid();
  }

  // Get current user data
  Future<UserEntity?> getCurrentUser() async {
    final userData = await _secureStorage.getUserDataAsync();
    if (userData != null) {
      try {
        return UserModel.fromJson(jsonDecode(userData));
      } catch (e) {
        debugPrint('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  // Debug method to check token state
  Future<void> debugTokenState() async {
    final token = await _secureStorage.getAccessTokenAsync();
    final userId = await _secureStorage.getUserIdAsync();
    
    debugPrint('=============== TOKEN DEBUG ===============');
    debugPrint('Has token in storage: ${token != null}');
    if (token != null) {
      debugPrint('Token length: ${token.length}');
      debugPrint('Token preview: ${token.substring(0, min(20, token.length))}...');
    }
    debugPrint('Has userId: ${userId != null}');
    debugPrint('Token in DioClient: ${_dioClient.hasValidToken()}');
    debugPrint('==========================================');
  }
}