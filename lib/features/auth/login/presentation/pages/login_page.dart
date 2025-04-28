import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:warehouse_scan/core/constants/app_routes.dart';
import 'package:warehouse_scan/core/widgets/logo_custom.dart';
import '../../../../../core/di/dependencies.dart' as di;
import '../../../../../core/widgets/error_dialog.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../widgets/login_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  final FocusNode _userIdFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    _userIdFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    
    return BlocProvider(
      create: (context) => di.sl<LoginBloc>(),
      child: BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        switch(state){
          case LoginSuccess():
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.warehouseMenu,
              (route) => false,
              arguments: state.user,
            );
          break;

          case LoginFailure():
            if(!context.mounted) break;
            ErrorDialog.show(
              context,
              title: 'LOGIN FAILED',
              message: state.message,
              onDismiss: () {
                if (context.mounted) {
                  context.read<LoginBloc>().add(ResetLoginStateEvent());
                }
              },
            );
          break;
        }
      },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF3a7bd5),
                  Color(0xFF3a6073),
                ],
              ),
            ),
            height: screenHeight,
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          buildLogoWidget(),
                          const SizedBox(height: 24),
                          
                          Expanded(
                            child: Form(
                              key: _formKey,
                              child: ListView(
                                physics: const ClampingScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                                  Card(
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    color: const Color(0xFF1d3557).withValues(alpha: 0.9),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          LoginTextField(
                                            controller: _userIdController,
                                            hintText: '请选择用户名',
                                            focusNode: _userIdFocusNode,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your username';
                                              }
                                              return null;
                                            },
                                            onFieldSubmitted: (_) {
                                              FocusScope.of(context).requestFocus(_passwordFocusNode);
                                            },
                                            onTap: () {
                                              FocusScope.of(context).canRequestFocus = true;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          LoginTextField(
                                            controller: _passwordController,
                                            hintText: '输入密码',
                                            obscureText: true,
                                            focusNode: _passwordFocusNode,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your password';
                                              }
                                              return null;
                                            },
                                            onFieldSubmitted: (_) {
                                              _dismissKeyboard();
                                            },
                                            onTap: () {
                                              FocusScope.of(context).canRequestFocus = true;
                                            },
                                          ),
                                          const SizedBox(height: 24),
                                          BlocBuilder<LoginBloc, LoginState>(
                                            builder: (context, state) {
                                              return LoginButton(
                                                isLoading: state is LoginLoading,
                                                onPressed: () {
                                                  _dismissKeyboard();
                                                  
                                                  if (_formKey.currentState!.validate()) {
                                                    context.read<LoginBloc>().add(
                                                      LoginButtonPressed(
                                                        userId: _userIdController.text,
                                                        password: _passwordController.text,
                                                        name: '資材出入',
                                                      ),
                                                    );
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (isKeyboardVisible)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}