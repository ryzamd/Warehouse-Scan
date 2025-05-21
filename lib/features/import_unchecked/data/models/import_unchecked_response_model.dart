import '../../domain/entities/import_unchecked_response_entity.dart';

class ImportUncheckedResponseModel extends ImportUncheckedResponseEntity {
  const ImportUncheckedResponseModel({
    required super.message,
    required super.results,
  });

  factory ImportUncheckedResponseModel.fromJson(List<dynamic> jsonList) {
    final results = jsonList
        .map((item) => ImportUncheckedResultModel.fromJson(item))
        .toList();

    return ImportUncheckedResponseModel(
      message: results.isNotEmpty ? 'Success' : 'No data',
      results: results,
    );
  }
}

class ImportUncheckedResultModel extends ImportUncheckedResultEntity {
  const ImportUncheckedResultModel({
    required super.code,
    required super.status,
    required super.updateMessage,
    super.errorMessage,
  });

  factory ImportUncheckedResultModel.fromJson(Map<String, dynamic> json) {
    final message = json['message'] ?? '';
    
    // THAY ĐỔI: Parse error message từ status khi không phải Success
    return ImportUncheckedResultModel(
      code: json['code'] ?? '',
      status: message,
      updateMessage: json['update_qc_qty_out'] ?? '',
      errorMessage: message != 'Success' ? message : null,
    );
  }
}