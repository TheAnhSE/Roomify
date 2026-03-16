import 'package:flutter/material.dart';

// Màu sắc theo Figma design — UI Guidelines PHẦN 5
class AppColors {
  // Màu chủ đạo
  static const primary = Color(0xFF29B6F6);      // blue-Sky từ Figma
  static const primaryDark = Color(0xFF0888C0);  // pressed / hover state

  // Backgrounds
  static const background = Color(0xFFFFFFFF);   // trắng — màu nền chính
  static const surface = Color(0xFFF5F5F5);      // nền card, input field
  static const surfaceDark = Color(0xFFEEEEEE);  // divider, border nhẹ

  // Text
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF757575);
  static const textHint = Color(0xFFBDBDBD);

  // Semantic
  static const error = Color(0xFFE53935);
  static const star = Color(0xFFFFC107);          // màu sao rating

  // Success screen (Register success, Booking success)
  static const successBackground = primary;       // nền xanh dương
  static const successText = Color(0xFFFFFFFF);

  // Status badge trong booking history
  static const statusConfirmed = Color(0xFF29B6F6);  // xanh dương = confirmed
  static const statusCancelled = Color(0xFFE53935);  // đỏ = cancelled
  static const statusCompleted = Color(0xFF9E9E9E);  // xám = completed
}
