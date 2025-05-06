import '../../domain/entities/batch_item_entity.dart';

class BatchItemModel extends BatchItemEntity {
  const BatchItemModel({
    required super.code,
    required super.name,
    super.quantity,
    super.unit,
    super.isProcessed,
    super.isError,
    super.errorMessage,
    super.oldAddress,
    super.quantiyImport,
    super.quantityExport,
  });

  factory BatchItemModel.fromJson(Map<String, dynamic> json) {
    return BatchItemModel(
      code: json['code'] ?? '',
      name: json['m_name'] ?? '',
      quantity: json['m_qty'] != null ? (json['m_qty'] is num ? (json['m_qty'] as num).toDouble() : 0.0) : 0.0,
      unit: json['m_unit'] ?? '',
      isProcessed: false,
      isError: false,
      errorMessage: '',
      oldAddress: json['zc_out_Warehouse_unit'] ?? '',
      quantiyImport: json['zc_warehouse_qty_int'] != null ? (json['zc_warehouse_qty_int'] is num ? (json['zc_warehouse_qty_int'] as num).toDouble() : 0.0) : 0.0,
      quantityExport: json['zc_warehouse_qty_out'] != null ? (json['zc_warehouse_qty_out'] is num ? (json['zc_warehouse_qty_out'] as num).toDouble() : 0.0) : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'm_name': name,
      'm_qty': quantity,
      'm_unit': unit,
      'zc_out_Warehouse_unit': oldAddress,
      'zc_warehouse_qty_int': quantiyImport,
      'zc_warehouse_qty_out': quantityExport,
    };
  }
}