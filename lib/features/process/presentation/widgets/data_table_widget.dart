import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_scan/core/constants/enum.dart';
import 'package:warehouse_scan/features/process/domain/entities/processing_item_entity.dart';
import 'package:warehouse_scan/features/process/presentation/bloc/processing_bloc.dart';
import 'package:warehouse_scan/features/process/presentation/bloc/processing_event.dart';
import 'package:warehouse_scan/features/process/presentation/bloc/processing_state.dart';

class ProcessingDataTable extends StatelessWidget {
  final UserRole userRole;
  
  const ProcessingDataTable({
    super.key,
    required this.userRole,
  });

  void _onSortColumn(BuildContext context, String column) {
    context.read<ProcessingBloc>().add(
      SortProcessingItemsEvent(
        column: column,
        ascending: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProcessingBloc, ProcessingState>(
      builder: (context, state) {
        if (state is ProcessingInitial || state is ProcessingLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProcessingError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is ProcessingLoaded || state is ProcessingRefreshing) {
          final items =
              state is ProcessingLoaded
                  ? state.filteredItems
                  : (state as ProcessingRefreshing).items;

          final sortColumn =
              state is ProcessingLoaded ? state.sortColumn : 'date';
          final ascending = state is ProcessingLoaded ? state.ascending : true;
          final isRefreshing = state is ProcessingRefreshing;

          return Stack(
            children: [
              Column(
                children: [
                  _buildTableHeader(context, sortColumn, ascending),
                  Expanded(
                    child:
                        items.isEmpty
                            ? const Center(child: Text('No data available'))
                            : _buildTableBody(items),
                  ),
                ],
              ),
              if (isRefreshing)
                const Positioned.fill(
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        }

        return const Center(child: Text('No data'));
      },
    );
  }

  Widget _buildTableHeader(BuildContext context, String sortColumn, bool ascending) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFF1d3557),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildHeaderCell('名稱', flex: 3),
          _buildHeaderCell('指令號', flex: 2),
          _buildHeaderCell('入庫數量', flex: 2),
          _buildHeaderCell('出庫數量', flex: 2),
          _buildHeaderCell(userRole == UserRole.warehouseIn ? '資材入庫' : '資材出庫',flex: 2),
          _buildHeaderCell('時間', flex: 2,
            onTap: () => _onSortColumn(context, 'date'),
            isSort: sortColumn == 'date',
            ascending: ascending
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
    String text, {
    int flex = 0,
    VoidCallback? onTap,
    bool isSort = false,
    bool ascending = false
  }) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isSort)
                SizedBox(
                  width: 10,
                  height: 20,
                  child: Icon(
                    ascending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableBody(List<ProcessingItemEntity> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Container(
          height: 50,
          color:
              index % 2 == 0
                  ? const Color(0xFFFAF1E6)
                  : const Color(0xFFF5E6CC),
          child: _buildDataRow(items[index]),
        );
      },
    );
  }

  Widget _buildDataRow(ProcessingItemEntity item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Text(
              item.mName,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Text(
              item.mPrjcode,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              item.qcQtyIn.toString(),
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              item.qcQtyOut.toString(),
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              userRole == UserRole.warehouseIn
                ? '${item.zcWarehouseQtyImport}'
                : '${item.zcWarehouseQtyExport}',
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Text(
              _formatDate(item.mDate),
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    
    // If date is in format "2024-03-02T00:00:00", convert to "2024-03-02"
    if (dateString.contains('T')) {
      return dateString.split('T')[0];
    }
    
    return dateString;
  }
}