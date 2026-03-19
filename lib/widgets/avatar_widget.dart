import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../core/constants/app_colors.dart';

Widget buildAvatar(UserModel user, {double radius = 20}) {
  if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(user.photoUrl!),
      onBackgroundImageError: (e, stack) {},
      child: null,
    );
  }
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
