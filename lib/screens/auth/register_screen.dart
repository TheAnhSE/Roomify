import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/auth_repository.dart';

// TODO (Người 2): Implement register screen theo Figma:
//   - Create Account.jpg → layout chính
// - Fields: fullName, phone, email, password, confirmPassword
// - Validation: email format, password >= 6 ký tự, passwords phải khớp
// - Nút "Đăng ký" với loading state (_isLoading)
// - Error message hiển thị bên dưới nút
// - Khi register thành công → AuthWrapper tự động redirect về MainScreen
// - Link "Đã có tài khoản?" → Navigator.pop() về LoginScreen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ignore: unused_field
  final _authRepo = AuthRepository();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // TODO: implement _onRegister

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
                  const Text('RegisterScreen — Người 2 implement'),
                  if (_errorMessage != null)
                    Text(_errorMessage!,
                        style: const TextStyle(color: AppColors.error)),
                ],
              ),
            ),
    );
  }
}
