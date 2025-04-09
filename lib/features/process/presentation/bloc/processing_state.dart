import 'package:equatable/equatable.dart';
import 'package:warehouse_scan/features/process/domain/entities/processing_item_entity.dart';

abstract class ProcessingState extends Equatable {
  const ProcessingState();

  @override
  List<Object> get props => [];
}

class ProcessingInitial extends ProcessingState {}

class ProcessingLoading extends ProcessingState {}

class ProcessingRefreshing extends ProcessingState {
  final List<ProcessingItemEntity> items;

  const ProcessingRefreshing({required this.items});

  @override
  List<Object> get props => [items];
}

class ProcessingLoaded extends ProcessingState {
  final List<ProcessingItemEntity> items;
  final List<ProcessingItemEntity> filteredItems;
  final String sortColumn;
  final bool ascending;
  final String searchQuery;
  final DateTime selectedDate;

  const ProcessingLoaded({
    required this.items,
    required this.filteredItems,
    required this.sortColumn,
    required this.ascending,
    this.searchQuery = '',
    required this.selectedDate
  });

  @override
  List<Object> get props => [
    items,
    filteredItems,
    sortColumn,
    ascending,
    searchQuery,
    selectedDate,
  ];

  ProcessingLoaded copyWith({
    List<ProcessingItemEntity>? items,
    List<ProcessingItemEntity>? filteredItems,
    String? sortColumn,
    bool? ascending,
    String? searchQuery,
    DateTime? selectedDate,
  }) {
    return ProcessingLoaded(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      sortColumn: sortColumn ?? this.sortColumn,
      ascending: ascending ?? this.ascending,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class ProcessingError extends ProcessingState {
  final String message;

  const ProcessingError({required this.message});

  @override
  List<Object> get props => [message];
}