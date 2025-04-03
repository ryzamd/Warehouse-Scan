// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  userId: json['userId'] as String,
  password: json['password'] as String,
  department: json['department'] as String,
  name: json['name'] as String,
  token: json['token'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'userId': instance.userId,
  'password': instance.password,
  'department': instance.department,
  'name': instance.name,
  'token': instance.token,
  'role': _$UserRoleEnumMap[instance.role]!,
};

const _$UserRoleEnumMap = {
  UserRole.warehouseIn: 'warehouseIn',
  UserRole.warehouseOut: 'warehouseOut',
};
