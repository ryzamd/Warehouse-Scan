import 'package:equatable/equatable.dart';

class ImportUncheckedItemEntity extends Equatable {
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
  final bool isError;
  final String errorMessage;

  const ImportUncheckedItemEntity({
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
    this.isError = false,
    this.errorMessage = '',
  });

  @override
  List<Object?> get props => [
        mwhId, mName, mDate, mVendor, mPrjcode, mQty, mUnit, mDocnum,
        mItemcode, cDate, code, staff, qtyState, zcWarehouseQtyImport,
        zcWarehouseQtyExport, isError, errorMessage,
      ];

  ImportUncheckedItemEntity copyWith({
    int? mwhId,
    String? mName,
    String? mDate,
    String? mVendor,
    String? mPrjcode,
    double? mQty,
    String? mUnit,
    String? mDocnum,
    String? mItemcode,
    String? cDate,
    String? code,
    String? staff,
    String? qtyState,
    double? zcWarehouseQtyImport,
    double? zcWarehouseQtyExport,
    bool? isError,
    String? errorMessage,
  }) {
    return ImportUncheckedItemEntity(
      mwhId: mwhId ?? this.mwhId,
      mName: mName ?? this.mName,
      mDate: mDate ?? this.mDate,
      mVendor: mVendor ?? this.mVendor,
      mPrjcode: mPrjcode ?? this.mPrjcode,
      mQty: mQty ?? this.mQty,
      mUnit: mUnit ?? this.mUnit,
      mDocnum: mDocnum ?? this.mDocnum,
      mItemcode: mItemcode ?? this.mItemcode,
      cDate: cDate ?? this.cDate,
      code: code ?? this.code,
      staff: staff ?? this.staff,
      qtyState: qtyState ?? this.qtyState,
      zcWarehouseQtyImport: zcWarehouseQtyImport ?? this.zcWarehouseQtyImport,
      zcWarehouseQtyExport: zcWarehouseQtyExport ?? this.zcWarehouseQtyExport,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}