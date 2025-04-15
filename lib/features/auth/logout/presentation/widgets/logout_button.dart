import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_scan/core/constants/app_routes.dart';
import '../../../../../core/widgets/confirmation_dialog.dart';
import '../../../../../core/widgets/error_dialog.dart';
import '../bloc/logout_bloc.dart';
import '../bloc/logout_event.dart';
import '../bloc/logout_state.dart';

class LogoutButton extends StatelessWidget {
  final double width;
  final double height;
  
  const LogoutButton({
    super.key,
    this.width = double.infinity,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutBloc, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        } else if (state is LogoutFailure) {
          ErrorDialog.show(
            context,
            title: 'Logout Failed',
            message: state.message,
          );
        }
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ConfirmationDialog.show(
              context,
              title: 'Confirm Logout',
              message: 'Are you sure you want to log out?',
              confirmText: 'Logout',
              cancelText: 'Cancel',
              confirmColor: Colors.red,
              onConfirm: () {
                context.read<LogoutBloc>().add(LogoutButtonPressed());
              },
              onCancel: () {},
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: BlocBuilder<LogoutBloc, LogoutState>(
              builder: (context, state) {
                if (state is LogoutLoading) {
                  return const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  );
                }
                return const Text(
                  'LOGOUT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}