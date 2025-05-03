import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_scan/core/constants/app_colors.dart';
import 'package:warehouse_scan/core/localization/context_extension.dart';
import '../bloc/address_bloc.dart';
import '../bloc/address_event.dart';
import '../bloc/address_state.dart';

class AddressSelector extends StatefulWidget {
  final String currentAddress;
  final ValueChanged<String> onAddressSelected;
  final bool enabled;
  
  const AddressSelector({
    super.key,
    required this.currentAddress,
    required this.onAddressSelected,
    this.enabled = true,
  });

  @override
  State<AddressSelector> createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(GetAddressListEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressBloc, AddressState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: TextEditingController(text: widget.currentAddress),
                enabled: widget.enabled,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: context.multiLanguage.enterOrSelectAddressHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: widget.currentAddress.isNotEmpty ? Colors.grey.shade600 : Colors.grey.shade400,
                      width: widget.currentAddress.isNotEmpty ? 2.0 : 1.0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.multiLanguage.enterOrSelectAddressValidationMessage;
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 5),
            Container(
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: const BorderRadius.all(Radius.circular(8))
              ),
              width: 40,
              child: _buildActionButton(state),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildActionButton(AddressState state) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Builder(
        builder: (context) {
          if (state is AddressLoading) {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            );
          }

          if (state is AddressError) {
            return IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: widget.enabled ? () {context.read<AddressBloc>().add(GetAddressListEvent());} : null,
            );
          }

          final List<String> addresses = state is AddressLoaded ? state.addresses.addresses : [];
          return IconButton(
            icon: const Icon(Icons.arrow_drop_down, size: 24, color: Colors.white),
            onPressed: (addresses.isEmpty || !widget.enabled)
                ? null
                : () {
                    _showAddressSelector(context, addresses);
                  },
          );
        },
      ),
    );
  }
  
  void _showAddressSelector(BuildContext context, List<String> addresses) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  context.multiLanguage.selectAddressTitleUPCASE,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.inputText
                  ),
                ),
              ),
              const Divider(color: Colors.grey,),
              Expanded(
                child: ListView.builder(
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        addresses[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      textColor: Colors.orangeAccent.shade700,
                      onTap: () {
                        widget.onAddressSelected(addresses[index]);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}