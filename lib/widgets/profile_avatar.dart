import 'dart:io';
import 'package:flutter/material.dart';
import 'package:study_sync/utils/profile_image_utils.dart';

class ProfileAvatar extends StatefulWidget {
  final String photoUrl;
  final String? localImagePath;
  final double radius;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.photoUrl,
    this.localImagePath,
    this.radius = 60,
    this.onTap,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

// SingleTickerProviderStateMixin handles the native loop for the rotation halo
class _ProfileAvatarState extends State<ProfileAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    // Continuous infinite layout spin calculation loops for background halo
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double innerRadius = widget.radius - 4;
    final double size = innerRadius * 2;

    final Color surfaceColor = theme.colorScheme.surface;
    final Color primaryAccent = theme.colorScheme.primary;
    final Color secondaryAccent = theme.colorScheme.secondary;
    final Color onSurfaceColor = theme.colorScheme.onSurface;

    final Color dynamicInputFill = Color.alphaBlend(
      primaryAccent.withOpacity(isDark ? 0.16 : 0.10),
      surfaceColor,
    );
    final Color dynamicTextBody = onSurfaceColor.withOpacity(0.45);

    // FIXED: Self-contained pressable scaling interactive framework replacing missing custom wrappers
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          height: widget.radius * 2 + 6,
          width: widget.radius * 2 + 6,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // FIXED: Rotation controller matrix replacing missing SlowRotate wrapper element
              RotationTransition(
                turns: _rotationController,
                child: Container(
                  height: widget.radius * 2 + 6,
                  width: widget.radius * 2 + 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        primaryAccent.withOpacity(0.0),
                        primaryAccent.withOpacity(0.9),
                        secondaryAccent.withOpacity(0.9),
                        primaryAccent.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.3, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // FIXED: Tween breathing matrix replacing missing Breathing structure block
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.99, end: 1.01),
                duration: const Duration(milliseconds: 1800),
                curve: Curves.easeInOutSine,
                builder: (context, scaleVal, child) {
                  return Transform.scale(scale: scaleVal, child: child);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryAccent, secondaryAccent.withOpacity(0.8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryAccent.withOpacity(isDark ? 0.2 : 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: surfaceColor,
                    ),
                    child: CircleAvatar(
                      radius: innerRadius,
                      backgroundColor: dynamicInputFill,
                      child: ClipOval(
                        child: _buildAnimatedImage(
                          size,
                          isDark,
                          dynamicTextBody,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedImage(double size, bool isDark, Color placeholderColor) {
    final String imagePath =
        widget.localImagePath != null && widget.localImagePath!.isNotEmpty
        ? widget.localImagePath!
        : widget.photoUrl;

    if (imagePath.isEmpty) return _placeholder(size, placeholderColor);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, opacityValue, child) {
        return Opacity(
          opacity: opacityValue,
          child: Transform.scale(
            scale: 0.95 + (0.05 * opacityValue),
            child: child,
          ),
        );
      },
      child: _resolveImageSource(imagePath, size, isDark, placeholderColor),
    );
  }

  Widget _resolveImageSource(
    String path,
    double size,
    bool isDark,
    Color placeholderColor,
  ) {
    final placeholder = _placeholder(size, placeholderColor);

    if (ProfileImageUtils.isNetworkUrl(path)) {
      return Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder;
        },
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    if (ProfileImageUtils.isAssetPath(path)) {
      return Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    if (ProfileImageUtils.isLocalFile(path)) {
      return Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    return placeholder;
  }

  Widget _placeholder(double size, Color color) {
    return Icon(Icons.person_rounded, size: size * 0.45, color: color);
  }
}
