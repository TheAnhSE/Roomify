import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/auth_repository.dart';

// TODO (Người 2): Implement login screen theo Figma:
//   - Login.jpg          → layout chính
//   - ForgotPassword.jpg  → flow "Quên mật khẩu?" bước 1
//   - ForgotPassword2.jpg → flow "Quên mật khẩu?" bước 2 (thông báo gửi email)
// - Email + password fields với validation
// - Nút "Đăng nhập" với loading state (_isLoading)
// - Error message hiển thị bên dưới nút
// - "Quên mật khẩu?" → gọi AuthRepository.resetPassword(), show SnackBar xác nhận
// - Link "Chưa có tài khoản?" → navigate đến RegisterScreen
// - Khi login thành công → AuthWrapper tự động redirect về MainScreen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ignore: unused_field
  final _authRepo = AuthRepository();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // TODO: implement _onLogin
  // TODO: implement _onForgotPassword

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('LoginScreen — Người 2 implement'),
                  if (_errorMessage != null)
                    Text(_errorMessage!,
                        style: const TextStyle(color: AppColors.error)),
                ],
              ),
            ),
    );
  }
}
