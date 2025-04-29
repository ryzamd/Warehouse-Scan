import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_scan/core/constants/app_colors.dart';

import '../../features/address/presentation/bloc/address_bloc.dart';
import '../../features/address/presentation/widgets/address_selector.dart';
import '../di/dependencies.dart' as di;

class BatchScanWarehouseDialog extends StatefulWidget {
  final Function(String address, double quantity, int operationMode) onProcessBatch;
  
  const BatchScanWarehouseDialog({
    super.key,
    required this.onProcessBatch,
  });
  
  static Future<void> show(
    BuildContext context, {
    required Function(String address, double quantity, int operationMode) onProcessBatch,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BatchScanWarehouseDialog(
        onProcessBatch: onProcessBatch,
      ),
    );
  }

  @override
  State<BatchScanWarehouseDialog> createState() => _BatchScanWarehouseDialogState();
}

class _BatchScanWarehouseDialogState extends State<BatchScanWarehouseDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  int _operationMode = 3;
  
  @override
  void dispose() {
    _addressController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'CONFIRM',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.error
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: BlocProvider(
        create: (_) => di.sl<AddressBloc>(),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Address:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AddressSelector(
                  currentAddress: _addressController.text,
                  onAddressSelected: (address) {
                    setState(() {
                      _addressController.text = address;
                    });
                  },
                  enabled: true,
                ),

                const SizedBox(height: 8),
                
                const Text(
                  'Quantity:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder(
                  valueListenable: _quantityController,
                  builder: (context, value, child){
                    return TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter Quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: value.text.isNotEmpty ? Colors.grey.shade600 : Colors.grey.shade400,
                            width: value.text.isNotEmpty ? 2.0 : 1.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        final quantity = double.tryParse(value);
                        if (quantity == null) {
                          return 'Please enter a valid number';
                        }
                        if (quantity <= 0) {
                          return 'Quantity must be greater than 0';
                        }
                        return null;
                      },
                    );
                  }
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Operation Mode:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<int>(
                        title: const Text('Export', style: TextStyle(fontSize: 14)),
                        value: 3,
                        groupValue: _operationMode,
                        onChanged: (value) {
                          setState(() {
                            _operationMode = value!;
                          });
                        },
                        activeColor: AppColors.error,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<int>(
                        title: const Text('Recall', style: TextStyle(fontSize: 14)),
                        value: 4,
                        groupValue: _operationMode,
                        onChanged: (value) {
                          setState(() {
                            _operationMode = value!;
                          });
                        },
                        activeColor: AppColors.error,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.error)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final address = _addressController.text;
                  final quantity = double.parse(_quantityController.text);
                  
                  Navigator.of(context).pop();
                  widget.onProcessBatch(address, quantity, _operationMode);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        )
      ],
    );
  }
}