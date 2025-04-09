import 'package:json_annotation/json_annotation.dart';
import 'package:warehouse_scan/features/process/domain/entities/processing_item_entity.dart';

part 'processing_item_model.g.dart';

@JsonSerializable()
class ProcessingItemModel extends ProcessingItemEntity {
  const ProcessingItemModel({
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
    required super.qcQtyIn,
    required super.qcQtyOut,
    required super.zcWarehouseQtyImport,
    required super.zcWarehouseQtyExport,
    required super.qtyState,
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

  @JsonKey(name: 'm_qty', defaultValue: 0.0)
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

  @JsonKey(name: 'qty_state', defaultValue: '')
  String get getQtyState => qtyState;

  factory ProcessingItemModel.fromJson(Map<String, dynamic> json) =>
      _$ProcessingItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProcessingItemModelToJson(this);
}