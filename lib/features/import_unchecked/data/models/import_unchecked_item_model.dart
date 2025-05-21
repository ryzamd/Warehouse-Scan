import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/import_unchecked_item_entity.dart';

part 'import_unchecked_item_model.g.dart';

@JsonSerializable()
class ImportUncheckedItemModel extends ImportUncheckedItemEntity {
  const ImportUncheckedItemModel({
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
    super.isError,
    super.errorMessage,
  });

  factory ImportUncheckedItemModel.fromJson(Map<String, dynamic> json) =>
      _$ImportUncheckedItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImportUncheckedItemModelToJson(this);

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