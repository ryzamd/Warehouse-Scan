import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_scan/core/constants/app_routes.dart';
import 'package:warehouse_scan/core/localization/context_extension.dart';
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
            title: context.multiLanguage.loginFailedUPCASE,
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
              title: context.multiLanguage.logoutDialogLabel,
              message: context.multiLanguage.logoutConfirmMessage,
              confirmText: context.multiLanguage.logoutButtonUPCASE,
              cancelText: context.multiLanguage.cancelButton,
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
                return Text(
                  context.multiLanguage.logoutButtonUPCASE,
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