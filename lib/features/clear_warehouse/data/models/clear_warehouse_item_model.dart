import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/clear_warehouse_item_entity.dart';

part 'clear_warehouse_item_model.g.dart';

@JsonSerializable()
class ClearWarehouseItemModel extends ClearWarehouseItemEntity {
  const ClearWarehouseItemModel({
    required super.mwhId,
    required super.mName,
    required super.mDate,
    required super.mVendor,
    required super.mPrjcode,
    required super.mQty,
    required super.mUnit,
    required super.mDocnum,
    required super.mItemcode,
    required super.cDate,
    required super.code,
    required super.staff,
    required super.qtyState,
    required super.zcWarehouseQtyImport,
    required super.zcWarehouseQtyExport,
    required super.zcWarehouseTimeOut,
  });

  factory ClearWarehouseItemModel.fromJson(Map<String, dynamic> json) =>
      _$ClearWarehouseItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClearWarehouseItemModelToJson(this);

  static double _qtyFromJson(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }
}