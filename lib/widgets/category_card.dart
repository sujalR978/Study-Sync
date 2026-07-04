import 'package:flutter/material.dart';
import 'package:study_sync/constants/app_colors.dart'; // Ensure path is correct

class CategoryCard extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  IconData getIcon() {
    switch (category) {
      case "Study":
        return Icons.school_outlined;
      case "Work":
        return Icons.work_outline_rounded;
      case "Personal":
        return Icons.person_outline_rounded;
      case "Health":
        return Icons.favorite_border_rounded;
      case "Shopping":
        return Icons.shopping_cart_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine background color based on theme selection context
    final Color unselectedBg = isDark
        ? AppColors.darkInputFill
        : const Color(0xFFE9EDF7);
    final Color unselectedContent = isDark
        ? AppColors.darkTextBody
        : const Color(0xFF4B5563);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height:
            50, // Slightly slimmed down to 50 for a premium, compact pill feel
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ), // Prevents wall-clipping
        decoration: BoxDecoration(
         
          color: isSelected ? AppColors.primary : unselectedBg,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize
              .min, // Allows the Wrap widget to bundle chips closely
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              getIcon(),
              
              color: isSelected ? Colors.white : unselectedContent,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              category,
              style: TextStyle(
                
                color: isSelected ? Colors.white : unselectedContent,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ], 
        ),
      ),
    );
  }
}
