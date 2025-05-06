import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_scan/core/localization/context_extension.dart';
import '../../domain/entities/batch_item_entity.dart';
import '../bloc/batch_scan_bloc.dart';
import '../bloc/batch_scan_event.dart';

class BatchItemList extends StatelessWidget {
  final List<BatchItemEntity> items;
  
  const BatchItemList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return  Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            context.multiLanguage.batchListNoItemsMessage,
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
  
  Widget _buildItemCard(BuildContext context, BatchItemEntity item) {
    final TextStyle titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: item.isError ? Colors.red : Colors.black87,
    );
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
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
                style: titleStyle,
              ),
            ),
            if (item.isError)
              const Icon(Icons.error, color: Colors.red, size: 16),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              context.multiLanguage.batchListNameWithValue(item.name),
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              context.multiLanguage.batchListQuantityWithValue(item.quantity, item.unit),
              style: const TextStyle(fontSize: 13),
            ),
            if (item.isError && item.quantiyImport == item.quantityExport) ...[
              const SizedBox(height: 2),
              Text(
                context.multiLanguage.batchListErrorWithValue(context.multiLanguage.alreadyShippedMessage),
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
            if (item.isError && item.quantity > (item.quantiyImport - item.quantityExport)) ...[
              const SizedBox(height: 2),
              Text(
                context.multiLanguage.batchListErrorWithValue(context.multiLanguage.quantityNotEnoughMessage),
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            context.read<BatchScanBloc>().add(
              RemoveFromBatchList(item.code),
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