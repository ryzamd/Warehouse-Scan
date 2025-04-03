import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_scan/core/auth/auth_repository.dart';
import 'package:warehouse_scan/core/di/dependencies.dart' as di;
import 'package:warehouse_scan/core/widgets/scafford_custom.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
import 'package:warehouse_scan/features/process/presentation/bloc/processing_bloc.dart';
import 'package:warehouse_scan/features/process/presentation/bloc/processing_event.dart';
import '../widgets/data_table_widget.dart';

class ProcessingPage extends StatefulWidget {
  final UserEntity? user;
  
  const ProcessingPage({super.key, required this.user});

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
  late final TextEditingController _searchController;
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    // Debug token state before loading data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      di.sl<AuthRepository>().debugTokenState().then((_) {
        if (mounted) {
          context.read<ProcessingBloc>().add(
            GetProcessingItemsEvent(userName: widget.user!.name)
          );
        }
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'PROCESSING',
      user: widget.user,
      currentIndex: 0,
      showBackButton: false,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search bar
            _buildSearchBar(),
            const SizedBox(height: 8),
            // Data table
            Expanded(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ProcessingDataTable(
                    userRole: widget.user!.role,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            // Refresh data
            context.read<ProcessingBloc>().add(
              RefreshProcessingItemsEvent(userName: widget.user!.name)
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Refreshing data...'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          tooltip: 'Refresh data',
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              // Clear search and reset data
              _searchController.clear();
              context.read<ProcessingBloc>().add(
                const SearchProcessingItemsEvent(query: ''),
              );
              FocusScope.of(context).unfocus();
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14
          ),
        ),
        onChanged: (value) {
          // Send search event when text changes
          context.read<ProcessingBloc>().add(
            SearchProcessingItemsEvent(query: value),
          );
        },
      ),
    );
  }
}