import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/warehouse_in_entity.dart';

part 'warehouse_in_model.g.dart';

@JsonSerializable()
class WarehouseInModel extends WarehouseInEntity {
  const WarehouseInModel({
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
    required super.inWarehouse,
  });

  @JsonKey(name: 'mwh_id', defaultValue: 0)
  int get getMwhId => mwhId;

  @JsonKey(name: 'm_name', defaultValue: '')
  String get getMName => mName;

  @JsonKey(name: 'm_date', defaultValue: '')
  String get getMDate => mDate;

  @JsonKey(name: 'm_vendor', defaultValue: '')
  String get getMVendor => mVendor;

  @JsonKey(name: 'm_prjcode', defaultValue: '')
  String get getMPrjcode => mPrjcode;

  @JsonKey(name: 'm_qty', defaultValue: 0.0, fromJson: _qtyFromJson)
  double get getMQty => mQty;

  @JsonKey(name: 'm_unit', defaultValue: '')
  String get getMUnit => mUnit;

  @JsonKey(name: 'm_docnum', defaultValue: '')
  String get getMDocnum => mDocnum;

  @JsonKey(name: 'm_itemcode', defaultValue: '')
  String get getMItemcode => mItemcode;

  @JsonKey(name: 'c_date', defaultValue: '')
  String get getCDate => cDate;

  @JsonKey(defaultValue: '')
  String get getCode => code;

  @JsonKey(defaultValue: '')
  String get getStaff => staff;

  @JsonKey(defaultValue: '')
  String get getQtyState => qtyState;

  @JsonKey(name: 'in_warehouse', defaultValue: '')
  String get getInWarehouse => inWarehouse;

  factory WarehouseInModel.fromJson(Map<String, dynamic> json) =>
      _$WarehouseInModelFromJson(json);

  Map<String, dynamic> toJson() => _$WarehouseInModelToJson(this);
  
  // Helper method to handle quantity conversion
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