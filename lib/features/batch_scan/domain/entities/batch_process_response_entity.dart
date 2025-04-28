import 'package:equatable/equatable.dart';

class BatchProcessResponseEntity extends Equatable {
  final String message;
  final List<BatchResultEntity> results;

  const BatchProcessResponseEntity({
    required this.message,
    required this.results,
  });

  @override
  List<Object?> get props => [message, results];
}

class BatchResultEntity extends Equatable {
  final String code;
  final String status;
  final double? quantity;
  final String? address;
  final String? userName;
  final int? operationMode;
  final String? errorMessage;

  const BatchResultEntity({
    required this.code,
    required this.status,
    this.quantity,
    this.address,
    this.userName,
    this.operationMode,
    this.errorMessage,
  });

  bool get isSuccess => status == 'Success';

  @override
  List<Object?> get props => [
    code,
    status,
    quantity,
    address,
    userName,
    operationMode,
    errorMessage
  ];
}