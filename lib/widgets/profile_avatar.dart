import 'dart:io';

import 'package:flutter/material.dart';
import 'package:study_sync/constants/app_colors.dart';
import 'package:study_sync/utils/profile_image_utils.dart';

class ProfileAvatar extends StatelessWidget {
  final String photoUrl;
  final String? localImagePath;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.photoUrl,
    this.localImagePath,
    this.radius = 60,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double size = radius * 2;

    return CircleAvatar(
      radius: radius,
      backgroundColor: isDark ? AppColors.darkInputFill : AppColors.inputFill,
      child: ClipOval(child: _buildImage(size, isDark)),
    );
  }

  Widget _buildImage(double size, bool isDark) {
    final placeholder = _placeholder(size, isDark);
    final imagePath =
        localImagePath != null && localImagePath!.isNotEmpty
            ? localImagePath!
            : photoUrl;

    if (imagePath.isEmpty) return placeholder;

    if (ProfileImageUtils.isNetworkUrl(imagePath)) {
      return Image.network(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    if (ProfileImageUtils.isAssetPath(imagePath)) {
      return Image.asset(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    if (ProfileImageUtils.isLocalFile(imagePath)) {
      return Image.file(
        File(imagePath),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    return placeholder;
  }

  Widget _placeholder(double size, bool isDark) {
    return Icon(
      Icons.person,
      size: size * 0.5,
      color: isDark ? AppColors.darkTextBody : AppColors.textBody,
    );
  }
}
