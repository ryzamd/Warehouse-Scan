import 'package:equatable/equatable.dart';

class InventoryItemEntity extends Equatable {
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
  final String zcInventory;
  final String address;

  const InventoryItemEntity({
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
    required this.zcInventory,
    required this.address,
  });

  @override
  List<Object?> get props => [
        mwhId, mName, mDate, mVendor, mPrjcode, mQty, mUnit, mDocnum,
        mItemcode, cDate, code, staff, qtyState, zcWarehouseQtyImport,
        zcWarehouseQtyExport, zcInventory, address
      ];
}