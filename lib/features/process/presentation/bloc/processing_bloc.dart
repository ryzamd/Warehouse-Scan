import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_scan/features/process/domain/entities/processing_item_entity.dart';
import 'package:warehouse_scan/features/process/domain/usecases/get_processing_items.dart';
import 'processing_event.dart';
import 'processing_state.dart';

class ProcessingBloc extends Bloc<ProcessingEvent, ProcessingState> {
  final GetProcessingItems getProcessingItems;

  ProcessingBloc({
    required this.getProcessingItems,
  }) : super(ProcessingInitial()) {
    on<GetProcessingItemsEvent>(_onGetProcessingItems);
    on<RefreshProcessingItemsEvent>(_onRefreshProcessingItems);
    on<SortProcessingItemsEvent>(_onSortProcessingItems);
    on<SearchProcessingItemsEvent>(_onSearchProcessingItems);
    on<SelectDateEvent>(_onSelectDate);
  }

  Future<void> _onGetProcessingItems(
    GetProcessingItemsEvent event,
    Emitter<ProcessingState> emit,
  ) async {
    emit(ProcessingLoading());

    try {
      final result = await getProcessingItems(GetProcessingParams(date: event.date));

      result.fold(
        (failure) => emit(ProcessingError(message: failure.message)),
        (items) {
          // Default sort by date
          final sortedItems = List<ProcessingItemEntity>.from(items);
          _sortItemsByDate(sortedItems, false);

          emit(
            ProcessingLoaded(
              items: items,
              filteredItems: sortedItems,
              sortColumn: 'date',
              ascending: false,
              selectedDate: DateTime.now(),
            ),
          );
        },
      );
    } catch (e) {
      emit(ProcessingError(message: 'Error loading data: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshProcessingItems(
    RefreshProcessingItemsEvent event,
    Emitter<ProcessingState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProcessingLoaded) {
      // Keep current state to avoid UI flashing
      final existingItems = List<ProcessingItemEntity>.from(currentState.items);

      emit(ProcessingRefreshing(items: existingItems));

      try {
        final result = await getProcessingItems(GetProcessingParams(date: event.date));

        result.fold(
          (failure) {
            // If API fails, keep current data
            emit(
              ProcessingLoaded(
                items: existingItems,
                filteredItems: _filterItems(
                  existingItems,
                  currentState.searchQuery,
                ),
                sortColumn: currentState.sortColumn,
                ascending: currentState.ascending,
                searchQuery: currentState.searchQuery,
                selectedDate: DateTime.now(),
              ),
            );

            // Show error
            emit(ProcessingError(message: failure.message));
          },
          (items) {
            // Apply current filters and sorting
            final filteredItems = _filterItems(
              items,
              currentState.searchQuery,
            );
            _sortItems(
              filteredItems,
              currentState.sortColumn,
              currentState.ascending,
            );

            emit(
              ProcessingLoaded(
                items: items,
                filteredItems: filteredItems,
                sortColumn: currentState.sortColumn,
                ascending: currentState.ascending,
                searchQuery: currentState.searchQuery,
                selectedDate: DateTime.now(),
              ),
            );
          },
        );
      } catch (e) {
        // Handle errors and keep current data
        emit(
          ProcessingLoaded(
            items: existingItems,
            filteredItems: _filterItems(
              existingItems,
              currentState.searchQuery,
            ),
            sortColumn: currentState.sortColumn,
            ascending: currentState.ascending,
            searchQuery: currentState.searchQuery,
            selectedDate: DateTime.now(),
          ),
        );

        emit(
          ProcessingError(message: 'Error refreshing data: ${e.toString()}'),
        );
      }
    } else {
      // If not in loaded state, initiate a fresh load
      add(GetProcessingItemsEvent(date: event.date));
    }
  }

  void _onSortProcessingItems(
    SortProcessingItemsEvent event,
    Emitter<ProcessingState> emit,
  ) {
    final currentState = state;
    if (currentState is ProcessingLoaded) {
      final sortedItems = List<ProcessingItemEntity>.from(
        currentState.filteredItems,
      );

      final sortColumn = event.column;
      final ascending = sortColumn == currentState.sortColumn
              ? !currentState.ascending
              : event.ascending;

      _sortItems(sortedItems, sortColumn, ascending);

      emit(
        currentState.copyWith(
          filteredItems: sortedItems,
          sortColumn: sortColumn,
          ascending: ascending,
        ),
      );
    }
  }

  void _onSearchProcessingItems(
    SearchProcessingItemsEvent event,
    Emitter<ProcessingState> emit,
  ) {
    final currentState = state;
    if (currentState is ProcessingLoaded) {
      final filteredItems = _filterItems(currentState.items, event.query);

      _sortItems(
        filteredItems,
        currentState.sortColumn,
        currentState.ascending,
      );

      emit(
        currentState.copyWith(
          filteredItems: filteredItems,
          searchQuery: event.query,
        ),
      );
    }
  }

  // Helper methods for sorting and filtering
  void _sortItems(
    List<ProcessingItemEntity> items,
    String column,
    bool ascending,
  ) {
    if (column == 'date') {
      _sortItemsByDate(items, ascending);
    }
  }

  void _sortItemsByDate(List<ProcessingItemEntity> items, bool ascending) {
    items.sort((a, b) {
      // Handle empty dates
      if (a.mDate.isEmpty) return ascending ? 1 : -1;
      if (b.mDate.isEmpty) return ascending ? -1 : 1;
      
      try {
        // Compare by date first
        DateTime dateA = DateTime.parse(a.mDate);
        DateTime dateB = DateTime.parse(b.mDate);
        int dateCompare = ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        
        // If dates are the same, use item name as secondary sort key
        if (dateCompare == 0) {
          return ascending ? a.mName.compareTo(b.mName) : b.mName.compareTo(a.mName);
        }
        
        return dateCompare;
      } catch (e) {
        // Fallback to string comparison if parsing fails
        return ascending ? a.mDate.compareTo(b.mDate) : b.mDate.compareTo(a.mDate);
      }
    });
  }

  List<ProcessingItemEntity> _filterItems(
    List<ProcessingItemEntity> items,
    String query,
  ) {
    if (query.isEmpty) {
      return List.from(items);
    }

    final lowercaseQuery = query.toLowerCase();

    return items.where((item) {
      // Search by name
      if (item.mName.isEmpty && item.mName.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }

      // Search by project code
      if (item.mPrjcode.isEmpty && item.mPrjcode.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }

      // Search by date
      if (item.mDate.isEmpty && item.mDate.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }

      // Search by quantity
      if (item.mQty.isNaN && item.mQty.toString().contains(lowercaseQuery)) {
        return true;
      }

      // Search by warehouse quantity in or out
      if (item.zcWarehouseQtyImport.toString().contains(lowercaseQuery)) {
        return true;
      }

      if (item.zcWarehouseQtyExport.toString().contains(lowercaseQuery)) {
        return true;
      }

      return false;
    }).toList();
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} 00:00:00';
  }

  Future<void> _onSelectDate(
    SelectDateEvent event,
    Emitter<ProcessingState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is ProcessingLoaded) {
      emit(currentState.copyWith(selectedDate: event.selectedDate));
      add(RefreshProcessingItemsEvent(date: _formatDateForApi(event.selectedDate)));
    } else {
      add(GetProcessingItemsEvent(date: _formatDateForApi(event.selectedDate)));
    }
  }

  String get formattedSelectedDate {
    if (state is ProcessingLoaded) {
      final date = (state as ProcessingLoaded).selectedDate;
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} 00:00:00';
    }
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} 00:00:00';
  }

  void loadData() {
    add(GetProcessingItemsEvent(date: formattedSelectedDate));
  }

  void refreshData() {
    add(RefreshProcessingItemsEvent(date: formattedSelectedDate));
  }
}