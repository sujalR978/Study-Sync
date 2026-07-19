import 'package:flutter/material.dart';

class CustomButton {
  // --- GOOGLE SIGN IN BUTTON ---
  static Widget gogalButton({
    required VoidCallback onPressed, 
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color onSurfaceColor = theme.colorScheme.onSurface;

    return _AnimatedPressable(
      onPressed: onPressed,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20), // Clean modern standard curvature match
          border: Border.all(
            color: isDark ? onSurfaceColor.withOpacity(0.08) : onSurfaceColor.withOpacity(0.12),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Standardizing a polished Material Icon framework replacement
            Icon(
              Icons.account_circle_rounded, 
              color: onSurfaceColor.withOpacity(0.8), 
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              "Continue with Google",
              style: TextStyle(
                color: onSurfaceColor,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STANDARD LOGIN / ACTION BUTTON ---
  static Widget loginButton({
    required String text,
    required VoidCallback onPressed,
    // UPGRADE: Accept context optionally or fallback implicitly via a dynamic layout builder injection
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final Color primaryAccent = theme.colorScheme.primary;
        final Color secondaryAccent = theme.colorScheme.secondary;

        return _AnimatedPressable(
          onPressed: onPressed,
          child: Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              // Gradient maps seamlessly to whatever primary/secondary colors are defined in the 8 themes
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryAccent,
                  secondaryAccent,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryAccent.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Internal reusable micro-scale controller handling spring interaction gestures out of the box
class _AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _AnimatedPressable({required this.child, required this.onPressed});

  @override
  State<_AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<_AnimatedPressable> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}