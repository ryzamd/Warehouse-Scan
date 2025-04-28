import '../../domain/entities/batch_process_response_entity.dart';

class BatchProcessResponseModel extends BatchProcessResponseEntity {
  const BatchProcessResponseModel({
    required super.message,
    required super.results,
  });

  factory BatchProcessResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> resultsJson = json['results'] ?? [];
    final results = resultsJson
        .map((resultJson) => BatchResultModel.fromJson(resultJson))
        .toList();

    return BatchProcessResponseModel(
      message: json['message'] ?? '',
      results: results,
    );
  }
}

class BatchResultModel extends BatchResultEntity {
  const BatchResultModel({
    required super.code,
    required super.status,
    super.quantity,
    super.address,
    super.userName,
    super.operationMode,
    super.errorMessage,
  });

  factory BatchResultModel.fromJson(Map<String, dynamic> json) {
    return BatchResultModel(
      code: json['code'] ?? '',
      status: json['status'] ?? '',
      quantity: json['qty'] != null ? (json['qty'] as num).toDouble() : null,
      address: json['address'],
      userName: json['userName'],
      operationMode: json['number'],
      errorMessage: json['error'],
    );
  }
}