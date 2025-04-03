import 'package:json_annotation/json_annotation.dart';
import 'package:warehouse_scan/core/constants/enum.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required super.userId,
    required super.password,
    required super.department,
    required super.name,
    required super.token,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Determine role based on name
    UserRole userRole = UserRole.warehouseIn; // Default
    
    if (json['user'] != null && json['user']['users'] != null) {
      final users = json['user']['users'];
      final name = users['name'] ?? '';
      
      if (name == '資材出庫') {
        userRole = UserRole.warehouseOut;
      } else if (name == '資材入庫') {
        userRole = UserRole.warehouseIn;
      }
      
      return UserModel(
        userId: users['userID'] ?? '',
        password: users['password'] ?? '',
        department: users['department'] ?? '',
        name: name,
        token: json['token'] ?? '',
        role: userRole,
      );
    }
    
    return _$UserModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}