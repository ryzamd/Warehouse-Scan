// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_unchecked_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportUncheckedItemModel _$ImportUncheckedItemModelFromJson(Map<String, dynamic> json) =>
    ImportUncheckedItemModel(
      mwhId: json['mwh_id'] != null ? (json['mwh_id'] as num).toInt() : 0,
      mName: json['m_name'] as String? ?? '',
      mDate: json['m_date'] as String? ?? '',
      mVendor: json['m_vendor'] as String? ?? '',
      mPrjcode: json['m_prjcode'] as String? ?? '',
      mQty: json['m_qty'] != null ? ImportUncheckedItemModel._qtyFromJson(json['m_qty']) : 0.0,
      mUnit: json['m_unit'] as String? ?? '',
      mDocnum: json['m_docnum'] as String? ?? '',
      mItemcode: json['m_itemcode'] as String? ?? '',
      cDate: json['c_date'] as String? ?? '',
      code: json['code'] as String? ?? '',
      staff: json['staff'] as String? ?? '',
      qtyState: json['qty_state'] as String? ?? '',
      zcWarehouseQtyImport: json['zc_warehouse_qty_int'] != null ? ImportUncheckedItemModel._qtyFromJson(json['zc_warehouse_qty_int']) : 0.0,
      zcWarehouseQtyExport: json['zc_warehouse_qty_out'] != null ? ImportUncheckedItemModel._qtyFromJson(json['zc_warehouse_qty_out']) : 0.0,
      isError: false,
      errorMessage: '',
    );

Map<String, dynamic> _$ImportUncheckedItemModelToJson(ImportUncheckedItemModel instance) =>
    <String, dynamic>{
      'mwh_id': instance.mwhId,
      'm_name': instance.mName,
      'm_date': instance.mDate,
      'm_vendor': instance.mVendor,
      'm_prjcode': instance.mPrjcode,
      'm_qty': instance.mQty,
      'm_unit': instance.mUnit,
      'm_docnum': instance.mDocnum,
      'm_itemcode': instance.mItemcode,
      'c_date': instance.cDate,
      'code': instance.code,
      'staff': instance.staff,
      'qty_state': instance.qtyState,
      'zc_warehouse_qty_int': instance.zcWarehouseQtyImport,
      'zc_warehouse_qty_out': instance.zcWarehouseQtyExport,
    };