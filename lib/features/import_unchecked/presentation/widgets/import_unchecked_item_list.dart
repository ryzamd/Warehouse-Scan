import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_scan/core/localization/context_extension.dart';
import '../../../../core/constants/key_code_constants.dart';
import '../../domain/entities/import_unchecked_item_entity.dart';
import '../bloc/import_unchecked_bloc.dart';
import '../bloc/import_unchecked_event.dart';

class ImportUncheckedItemList extends StatelessWidget {
  final List<ImportUncheckedItemEntity> items;
  
  const ImportUncheckedItemList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            context.multiLanguage.noDataMessage,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(context, item);
      },
    );
  }
  
  Widget _buildItemCard(BuildContext context, ImportUncheckedItemEntity item) {
    final Color titleColor = item.isError ? Colors.red : Colors.black87;
    final Color cardBorderColor = item.isError ? Colors.red : Colors.transparent;
        
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: cardBorderColor, width: item.isError ? 2 : 0),
      ),
      color: item.isError ? Colors.red.shade50 : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                context.multiLanguage.batchListCodeWithValue(_truncateCode(item.code)),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: titleColor,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              context.multiLanguage.batchListNameWithValue(item.mName),
              style: TextStyle(
                fontSize: 13,
                color: item.isError ? Colors.red.shade700 : Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              context.multiLanguage.batchListQuantityWithValue(item.mQty, item.mUnit),
              style: TextStyle(
                fontSize: 13,
                color: item.isError ? Colors.red.shade700 : Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              context.multiLanguage.qcStatusMessage(
                item.qtyState == KeyModalServerResponse.STATUS_QC
                  ? context.multiLanguage.notInspectByQCMessage
                  : context.multiLanguage.inspectByQCMessage,
              ),
              style: const TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            context.read<ImportUncheckedBloc>().add(
              RemoveFromImportUncheckedList(item.code),
            );
          },
        ),
      ),
    );
  }
  
  String _truncateCode(String code) {
    if (code.length <= 10) return code;
    return '${code.substring(0, 6)}...${code.substring(code.length - 4)}';
  }
}