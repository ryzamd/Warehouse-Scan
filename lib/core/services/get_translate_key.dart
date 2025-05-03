import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StringKey {
  static const String serverErrorMessage = "serverErrorMessage";
  static const String networkErrorMessage = "networkErrorMessage";
  static const String batchItemAlreadyExistsMessage = "batchItemAlreadyExistsMessage";
  static const String batchIsEmptyMessage = "batchIsEmptyMessage";
  static const String errorCheckingItemMessage = "errorCheckingItemMessage";
  static const String dataHasAlreadyBeenStored = "dataHasAlreadyBeenStored";
  static const String materialWithCodeNotFoundMessage = "materialWithCodeNotFoundMessage";
  static const String failedToGetMaterialInformation = "failedToGetMaterialInformation";
  static const String failedToProcessExportingWarehouse = "failedToProcessExportingWarehouse";
  static const String materialsSavedInWarehouseMessage = "materialsSavedInWarehouseMessage";
  static const String thisItemHasBeenScannedMessage = "thisItemHasBeenScannedMessage";
  static const String errorWhileCheckingMaterialMessage = "errorWhileCheckingMaterialMessage";
  static const String materialIsEmptyMessage = "materialIsEmptyMessage";
  static const String cannotSavingInventoryListMessage = "cannotSavingInventoryListMessage";
  static const String materialNotFound = "materialNotFound";
  static const String invalidCredentialsMessage = "invalidCredentialsMessage";
  static const String validateTokenMessage = "validateTokenMessage";
  static const String failedToLoadProcessItemsMessage = "failedToLoadProcessItemsMessage";
  static const String processingFetchDataFailedMessage = "processingFetchDataFailedMessage";
  static const String getAddressListFailedMessage = "getAddressListFailedMessage";
  static const String somethingWentWrongMessage = "somethingWentWrongMessage";
  static const String cannotGetProcessingItemsMessage = "cannotGetProcessingItemsMessage";
}

class TranslateKey {
  static String getStringKey(AppLocalizations l10n, String key, {Map<String, dynamic>? args}) {
    switch (key) {
      case StringKey.serverErrorMessage:
        return l10n.serverErrorMessage;

      case StringKey.networkErrorMessage:
        return l10n.networkErrorMessage;

      case StringKey.batchItemAlreadyExistsMessage:
        return l10n.batchItemAlreadyExistsMessage;
      
      case StringKey.batchIsEmptyMessage:
        return l10n.batchIsEmptyMessage;

      case StringKey.errorCheckingItemMessage:
        return l10n.errorCheckingItemMessage(args?['error'] ?? '');

      case StringKey.dataHasAlreadyBeenStored:
        return l10n.dataHasAlreadyBeenStoredMessage;

      case StringKey.materialWithCodeNotFoundMessage:
        return l10n.materialWithCodeNotFoundMessage(args?['code'] ?? '');
      
      case StringKey.failedToGetMaterialInformation:
        return l10n.failedToGetMaterialInformation;

      case StringKey.failedToProcessExportingWarehouse:
        return l10n.failedToProcessExportingWarehouse;

      case StringKey.materialsSavedInWarehouseMessage:
        return l10n.materialsSavedInWarehouseMessage;

      case StringKey.thisItemHasBeenScannedMessage:
        return l10n.thisItemHasBeenScannedMessage;

      case StringKey.errorWhileCheckingMaterialMessage:
        return l10n.errorWhileCheckingMaterialMessage;

      case StringKey.materialIsEmptyMessage:
        return l10n.materialIsEmptyMessage;

      case StringKey.cannotSavingInventoryListMessage:
        return l10n.cannotSavingInventoryListMessage;

      case StringKey.materialNotFound:
        return l10n.materialNotFoundMessage;

      case StringKey.invalidCredentialsMessage:
        return l10n.invalidCredentialsMessage;

      case StringKey.validateTokenMessage:
        return l10n.validateTokenMessage;

      case StringKey.failedToLoadProcessItemsMessage:
        return l10n.failedToLoadProcessItemsMessage;

      case StringKey.processingFetchDataFailedMessage:
        return l10n.processingFetchDataFailedMessage;

      case StringKey.getAddressListFailedMessage:
        return l10n.getAddressListFailedMessage;

      case StringKey.somethingWentWrongMessage:
        return l10n.somethingWentWrongMessage;

      case StringKey.cannotGetProcessingItemsMessage:
        return l10n.cannotGetProcessingItemsMessage;

      default:
        return 'Cannot find String key';
    }
  }
}