// lib/features/warehouse_scan/domain/entities/warehouse_out_entity.dart
import 'package:equatable/equatable.dart';

class WarehouseOutEntity extends Equatable {
  final int mwhId;
  final String mName;
  final String mDate;
  final String mVendor;
  final String mPrjcode;
  final double mQty;
  final String mUnit;
  final String mDocnum;
  final String mItemcode;
  final String cDate;
  final String code;
  final String staff;
  final String qtyState;
  final double zcWarehouseQtyImport;
  final double zcWarehouseQtyExport;

  const WarehouseOutEntity({
    required this.mwhId,
    required this.mName,
    required this.mDate,
    required this.mVendor,
    required this.mPrjcode,
    required this.mQty,
    required this.mUnit,
    required this.mDocnum,
    required this.mItemcode,
    required this.cDate,
    required this.code,
    required this.staff,
    required this.qtyState,
    required this.zcWarehouseQtyImport,
    required this.zcWarehouseQtyExport,
  });

  @override
  List<Object?> get props => [
        mwhId,
        mName,
        mDate,
        mVendor,
        mPrjcode,
        mQty,
        mUnit,
        mDocnum,
        mItemcode,
        cDate,
        code,
        staff,
        qtyState,
        zcWarehouseQtyImport,
        zcWarehouseQtyExport,
      ];
}