import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_scan/core/auth/auth_repository.dart';
import 'package:warehouse_scan/core/di/dependencies.dart' as di;
import 'package:warehouse_scan/core/localization/context_extension.dart';
import 'package:warehouse_scan/core/widgets/scafford_custom.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
import 'package:warehouse_scan/features/process/presentation/bloc/processing_bloc.dart';
import 'package:warehouse_scan/features/process/presentation/bloc/processing_event.dart';
import 'package:warehouse_scan/features/process/presentation/bloc/processing_state.dart';
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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      di.sl<AuthRepository>().debugTokenState().then((_) {
        if (mounted) {
          context.read<ProcessingBloc>().loadData();
        }
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {

    final currentState = context.read<ProcessingBloc>().state;
    final DateTime initialDate = currentState is ProcessingLoaded ? currentState.selectedDate : DateTime.now();
        
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if(!context.mounted) return;

    if (picked != null && picked != initialDate) {
      context.read<ProcessingBloc>().add(SelectDateEvent(selectedDate: picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: context.multiLanguage.processPageTitleUPCASE,
      user: widget.user,
      showHomeIcon: true,
      currentIndex: 0,
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            
            _buildSearchBar(),
            const SizedBox(height: 8),

            Expanded(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ProcessingDataTable(
                    user: widget.user!
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_month, color: Colors.white),
          onPressed: () {
            _selectDate(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            context.read<ProcessingBloc>().refreshData();
          },
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
          hintText: context.multiLanguage.searchHintLabel,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
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
          context.read<ProcessingBloc>().add(
            SearchProcessingItemsEvent(query: value),
          );
        },
      ),
    );
  }
}