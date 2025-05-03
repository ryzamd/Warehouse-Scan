class BatchInventoryResponseModel {
  final String message;
  final List<BatchInventoryResultModel> results;

  BatchInventoryResponseModel({
    required this.message,
    required this.results,
  });

  factory BatchInventoryResponseModel.fromJson(Map<String, dynamic> json) {
    final results = (json['results'] as List<dynamic>)
        .map((item) => BatchInventoryResultModel.fromJson(item))
        .toList();

    return BatchInventoryResponseModel(
      message: json['message'] ?? '',
      results: results,
    );
  }
}

class BatchInventoryResultModel {
  final String code;
  final String status;
  final String message;
  final String? zcInventory;

  BatchInventoryResultModel({
    required this.code,
    required this.status,
    required this.message,
    this.zcInventory,
  });

  factory BatchInventoryResultModel.fromJson(Map<String, dynamic> json) {
    return BatchInventoryResultModel(
      code: json['code'] ?? '',
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      zcInventory: json['zc_inventory'],
    );
  }

  bool get isSuccess => status == 'Success';
  bool get isInventoried => status == 'Inventoried';
  bool get isNotFound => status == 'NotFound';
  bool get hasError => !isSuccess && !isInventoried;
}