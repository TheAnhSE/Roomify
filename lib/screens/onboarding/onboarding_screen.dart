import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// TODO (Người 2): Implement onboarding screen theo Figma page-0002 ~ page-0003
// - 3 trang slide giới thiệu app
// - Nút "Bỏ qua" và "Tiếp theo"
// - Trang cuối: nút "Bắt đầu" → navigate đến LoginScreen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text('OnboardingScreen — Người 2 implement'),
      ),
    );
  }
}
