// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'processing_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProcessingItemModel _$ProcessingItemModelFromJson(Map<String, dynamic> json) =>
    ProcessingItemModel(
      mwhId: json['mwh_id'] != null ? (json['mwh_id'] as num).toInt() : 0,
      mName: json['m_name'] as String? ?? "",
      mDate: json['m_date'] as String? ?? "",
      mVendor: json['m_vendor'] as String? ?? "",
      mPrjcode: json['m_prjcode'] as String? ?? "",
      mQty: json['m_qty'] != null ? (json['m_qty'] as num).toDouble() : 0.0,
      mUnit: json['m_unit'] as String? ?? "",
      mDocnum: json['m_docnum'] as String? ?? "",
      mItemcode: json['m_itemcode'] as String? ?? "",
      cDate: json['c_date'] as String? ?? "",
      code: json['code'] as String? ?? "",
      staff: json['staff'] as String? ?? "",
      qcCheckTime: json['qcCheckTime'] as String? ?? "",
      qcScanTime: json['qcScanTime'] as String? ?? "",
      qcQtyIn: json['qc_qty_in'] != null ? (json['qc_qty_in'] as num).toInt() : 0,
      qcQtyOut: json['qc_qty_out'] != null ? (json['qc_qty_out'] as num).toInt() : 0,
      zcWarehouseQtyInt: json['zc_warehouse_qty_int'] != null ? (json['zc_warehouse_qty_int'] as num).toInt() : 0,
      zcWarehouseQtyOut: json['zc_warehouse_qty_out'] != null ? (json['zc_warehouse_qty_out'] as num).toInt() : 0,
      zcWarehouseTimeInt: json['zcWarehouseTimeInt'] as String? ?? "",
      zcWarehouseTimeOut: json['zcWarehouseTimeOut'] as String? ?? "",
      zcOutWarehouseUnit: json['zcOutWarehouseUnit'] as String? ?? "",
      zcUpInQtyTime: json['zcUpInQtyTime'] as String? ?? "",
      qcUpInQtyTime: json['qcUpInQtyTime'] as String? ?? "",
      zcInQcQtyTime: json['zcInQcQtyTime'] as String? ?? "",
      qtyState: json['qtyState'] as String? ?? "",
      adminAllDataTime: json['adminAllDataTime'] as String? ?? "",
      codeBonded: json['codeBonded'] as String? ?? "",
    );

Map<String, dynamic> _$ProcessingItemModelToJson(
  ProcessingItemModel instance,
) => <String, dynamic>{
  'mwhId': instance.mwhId,
  'mName': instance.mName,
  'mDate': instance.mDate,
  'mVendor': instance.mVendor,
  'mPrjcode': instance.mPrjcode,
  'mQty': instance.mQty,
  'mUnit': instance.mUnit,
  'mDocnum': instance.mDocnum,
  'mItemcode': instance.mItemcode,
  'cDate': instance.cDate,
  'code': instance.code,
  'staff': instance.staff,
  'qcCheckTime': instance.qcCheckTime,
  'qcScanTime': instance.qcScanTime,
  'qcQtyIn': instance.qcQtyIn,
  'qcQtyOut': instance.qcQtyOut,
  'zcWarehouseQtyInt': instance.zcWarehouseQtyInt,
  'zcWarehouseQtyOut': instance.zcWarehouseQtyOut,
  'zcWarehouseTimeInt': instance.zcWarehouseTimeInt,
  'zcWarehouseTimeOut': instance.zcWarehouseTimeOut,
  'zcOutWarehouseUnit': instance.zcOutWarehouseUnit,
  'zcUpInQtyTime': instance.zcUpInQtyTime,
  'qcUpInQtyTime': instance.qcUpInQtyTime,
  'zcInQcQtyTime': instance.zcInQcQtyTime,
  'qtyState': instance.qtyState,
  'adminAllDataTime': instance.adminAllDataTime,
  'codeBonded': instance.codeBonded,
};
