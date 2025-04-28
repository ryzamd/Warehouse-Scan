import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            'No data',
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
          'Code: ${_truncateCode(item.code)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Name: ${item.mName}',
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'Quantity: ${item.mQty} ${item.mUnit}',
              style: const TextStyle(fontSize: 13),
            ),
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