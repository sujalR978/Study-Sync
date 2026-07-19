import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class customText {
  static Widget titalText(String text, {required BuildContext context}) {
    final theme = Theme.of(context);
    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryColor, secondaryColor],
      ).createShader(bounds),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: Colors.white, // Critical backdrop fallback for programmatic blending
          letterSpacing: -0.8,
        ),
      ),
    );
  }

  static Widget opacityText(String text, {required BuildContext context}) {
    final theme = Theme.of(context);
    final Color onSurfaceColor = theme.colorScheme.onSurface;

    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        // Automatically reads the active theme's body text coloring token
        color: onSurfaceColor.withOpacity(0.65),
        letterSpacing: -0.2,
      ),
    );
  }
}

class CustomTextfield {
  static Widget customTextField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? valideter,
    List<TextInputFormatter>? regex,
    required TextEditingController controller,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    
    final Color primaryColor = theme.colorScheme.primary;
    final Color surfaceColor = theme.colorScheme.surface;
    final Color onSurfaceColor = theme.colorScheme.onSurface;

    // UPGRADE: Uses direct tint math via Alpha Blending instead of hardcoded theme models.
    // This perfectly calculates input backgrounds for all 8 light/dark profiles dynamically.
    final Color dynamicInputFill = Color.alphaBlend(
      primaryColor.withOpacity(isDark ? 0.12 : 0.06),
      surfaceColor,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: valideter,
        inputFormatters: regex,
        style: TextStyle(
          color: onSurfaceColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: onSurfaceColor.withOpacity(0.35),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              icon,
              color: onSurfaceColor.withOpacity(0.6),
              size: 22,
            ),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: dynamicInputFill,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 2,
            ),
          ),
          errorStyle: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}