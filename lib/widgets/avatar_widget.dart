import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../core/constants/app_colors.dart';

Widget buildAvatar(UserModel user, {double radius = 20}) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: AppColors.primary,
    child: Text(
      user.initials,
      style: TextStyle(
        fontSize: radius * 0.8,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
