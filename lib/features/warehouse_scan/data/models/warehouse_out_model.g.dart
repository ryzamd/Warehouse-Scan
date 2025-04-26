// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouse_out_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WarehouseOutModel _$WarehouseOutModelFromJson(Map<String, dynamic> json) =>
    WarehouseOutModel(
      mwhId: json['mwh_id'] != null ? (json['mwh_id'] as num).toInt() : 0,
      mName: json['m_name'] as String? ?? '',
      mDate: json['m_date'] as String? ?? '',
      mVendor: json['m_vendor'] as String? ?? '',
      mPrjcode: json['m_prjcode'] as String? ?? '',
      mQty: json['m_qty'] != null ? (json['m_qty'] as num).toDouble() : 0.0,
      zcWarehouseQtyImport: json['zc_warehouse_qty_int'] != null ? (json['zc_warehouse_qty_int'] as num).toDouble() : 0.0,
      zcWarehouseQtyExport: json['zc_warehouse_qty_out'] != null ? (json['zc_warehouse_qty_out'] as num).toDouble() : 0.0,
      mUnit: json['m_unit'] as String? ?? '',
      mDocnum: json['m_docnum'] as String? ?? '',
      mItemcode: json['m_itemcode'] as String? ?? '',
      cDate: json['c_date'] as String? ?? '',
      code: json['code'] as String? ?? '',
      staff: json['staff'] as String? ?? '',
      qtyState: json['qty_state'] as String? ?? '',
      address: json['zc_out_Warehouse_unit'] as String? ?? '',
    );

Map<String, dynamic> _$WarehouseOutModelToJson(WarehouseOutModel instance) =>
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
      'address': instance.address,
    };
