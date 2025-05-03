import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_scan/core/localization/context_extension.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../bloc/inventory_check_bloc.dart';
import '../bloc/inventory_check_event.dart';

class InventoryItemList extends StatelessWidget {
  final List<InventoryItemEntity> items;
  
  const InventoryItemList({
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
  
  Widget _buildItemCard(BuildContext context, InventoryItemEntity item) {
    final Color titleColor = item.isError ? Colors.red : (item.isInventoried ? Colors.orange : Colors.black87);
        
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
        title: Text(
          context.multiLanguage.batchListCodeWithValue(_truncateCode(item.code)),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: titleColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              context.multiLanguage.batchListNameWithValue(item.mName),
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              context.multiLanguage.batchListQuantityWithValue(item.mQty, item.mUnit),
              style: const TextStyle(fontSize: 13),
            ),
            if (item.statusMessage.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                "Error: ${item.statusMessage}",
                style: TextStyle(
                  fontSize: 12,
                  color: item.isError ? Colors.red : Colors.orange,
                ),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            context.read<InventoryCheckBloc>().add(
              RemoveFromInventoryList(item.code),
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