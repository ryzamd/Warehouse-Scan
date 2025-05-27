import 'package:flutter/material.dart';
import 'package:warehouse_scan/core/localization/context_extension.dart';
import '../view_models/warehouse_item_view_model.dart';

class WarehouseItemInfoWidget extends StatelessWidget {
  final WarehouseItemViewModel viewModel;
  final VoidCallback? onRemovePressed;

  const WarehouseItemInfoWidget({
    super.key,
    this.onRemovePressed,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
     return Container(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFFAF1E6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildInfoRow(context, context.multiLanguage.materialNameLabel, viewModel.displayName),
                  _buildDivider(),
                  _buildInfoRow(context, context.multiLanguage.materialProjectCode, viewModel.displayProjectCode),
                  _buildDivider(),
                  _buildInfoRow(context, context.multiLanguage.materialImport, viewModel.displayImportMaterial),
                  _buildDivider(),
                  _buildInfoRow(context, context.multiLanguage.materialExport, viewModel.displayExportMaterial),
                  _buildDivider(),
                  _buildInfoRow(context, context.multiLanguage.materialExportTime, viewModel.displayTimeOfExport),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isNoData = value == 'No data';
    final screenHeight = MediaQuery.of(context).size.height;
    final rowHeight = screenHeight * 0.09;
    
    return SizedBox(
      height: rowHeight,
      child: Row(
        children: [
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF4158A6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isNoData ? Colors.grey.shade600 : Colors.black87,
                  fontStyle: isNoData ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDivider() {
    return const SizedBox(height: 2);
  }
}