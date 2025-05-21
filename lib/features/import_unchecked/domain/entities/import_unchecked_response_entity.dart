import 'package:equatable/equatable.dart';

class ImportUncheckedResponseEntity extends Equatable {
  final String message;
  final List<ImportUncheckedResultEntity> results;

  const ImportUncheckedResponseEntity({
    required this.message,
    required this.results,
  });

  @override
  List<Object?> get props => [message, results];
}

class ImportUncheckedResultEntity extends Equatable {
  final String code;
  final String status;
  final String updateMessage;
  final String? errorMessage;

  const ImportUncheckedResultEntity({
    required this.code,
    required this.status,
    required this.updateMessage,
    this.errorMessage,
  });

  bool get isSuccess => status == 'Success';
  bool get isFailed => status != 'Success' && code.isNotEmpty;

  @override
  List<Object?> get props => [code, status, updateMessage, errorMessage];
}