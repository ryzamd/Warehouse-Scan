import 'package:equatable/equatable.dart';

class ProcessingItemEntity extends Equatable {
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
  final int qcQtyIn;
  final int qcQtyOut;
  final int zcWarehouseQtyImport;
  final int zcWarehouseQtyExport;
  final String qtyState;

  const ProcessingItemEntity({
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
    required this.qcQtyIn,
    required this.qcQtyOut,
    required this.zcWarehouseQtyImport,
    required this.zcWarehouseQtyExport,
    required this.qtyState,
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
        qcQtyIn,
        qcQtyOut,
        zcWarehouseQtyImport,
        zcWarehouseQtyExport,
        qtyState,
      ];
}