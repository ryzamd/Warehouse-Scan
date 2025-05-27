// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clear_warehouse_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClearWarehouseItemModel _$ClearWarehouseItemModelFromJson(Map<String, dynamic> json) =>
    ClearWarehouseItemModel(
      mwhId: json['mwh_id'] != null ? (json['mwh_id'] as num).toInt() : 0,
      mName: json['m_name'] as String? ?? '',
      mDate: json['m_date'] as String? ?? '',
      mVendor: json['m_vendor'] as String? ?? '',
      mPrjcode: json['m_prjcode'] as String? ?? '',
      mQty: json['m_qty'] != null ? (json['m_qty'] as num).toDouble() : 0.0,
     zcWarehouseQtyImport: json['zc_warehouse_qty_int'] != null ? ClearWarehouseItemModel._qtyFromJson(json['zc_warehouse_qty_int']) : 0.0,
      zcWarehouseQtyExport: json['zc_warehouse_qty_out'] != null ? ClearWarehouseItemModel._qtyFromJson(json['zc_warehouse_qty_out']) : 0.0,
      mUnit: json['m_unit'] as String? ?? '',
      mDocnum: json['m_docnum'] as String? ?? '',
      mItemcode: json['m_itemcode'] as String? ?? '',
      cDate: json['c_date'] as String? ?? '',
      code: json['code'] as String? ?? '',
      staff: json['staff'] as String? ?? '',
      qtyState: json['qty_state'] as String? ?? '',
      zcWarehouseTimeOut: json['zc_warehouse_time_out'] as String? ?? '',
    );

Map<String, dynamic> _$ClearWarehouseItemModelToJson(ClearWarehouseItemModel instance) =>
    <String, dynamic>{
      'mwhId': instance.mwhId,
      'mName': instance.mName,
      'mDate': instance.mDate,
      'mVendor': instance.mVendor,
      'mPrjcode': instance.mPrjcode,
      'mQty': instance.mQty,
      'mUnit': instance.mUnit,
      'mDocnum': instance.mDocnum,
      'mItemcode': instance.mItemcode,
      'zcWarehouseQtyImport': instance.zcWarehouseQtyImport,
      'zcWarehouseQtyExport': instance.zcWarehouseQtyExport,
      'cDate': instance.cDate,
      'code': instance.code,
      'staff': instance.staff,
      'qtyState': instance.qtyState,
    };
