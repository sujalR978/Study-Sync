import 'package:flutter/material.dart';

class CategoryCard extends StatefulWidget {
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

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _isPressed = false;

  IconData _getCategoryIcon() {
    switch (widget.category) {
      case "Study":
        return Icons.school_rounded;
      case "Work":
        return Icons.work_rounded;
      case "Personal":
        return Icons.person_rounded;
      case "Health":
        return Icons.favorite_rounded;
      case "Shopping":
        return Icons.shopping_cart_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color primaryColor = theme.colorScheme.primary;
    final Color surfaceColor = theme.colorScheme.surface;
    final Color onSurfaceColor = theme.colorScheme.onSurface;

    // UPGRADE: Alpha blending handles clean contrast levels for all 8 light/dark background variations
    final Color unselectedBg = Color.alphaBlend(
      primaryColor.withOpacity(isDark ? 0.12 : 0.06),
      surfaceColor,
    );
    final Color unselectedContent = onSurfaceColor.withOpacity(0.6);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 48, // Premium compact pill sizing
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: widget.isSelected ? primaryColor : unselectedBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isSelected 
                  ? Colors.transparent 
                  : (isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02)),
              width: 1.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(),
                color: widget.isSelected ? Colors.white : unselectedContent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                widget.category,
                style: TextStyle(
                  color: widget.isSelected ? Colors.white : unselectedContent,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}