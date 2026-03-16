import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// TODO (Người 2): Implement onboarding screen theo Figma:
//   - Onboarding.jpg  → layout tổng thể (dots indicator + nút điều hướng)
//   - Onboarding1.jpg → slide 1 nội dung
//   - Onboarding2.jpg → slide 2 nội dung
//   - Onboarding3.jpg → slide 3 nội dung
// - 3 trang slide giới thiệu app (PageView)
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
