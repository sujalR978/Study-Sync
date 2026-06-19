import 'package:flutter/material.dart';
import 'package:study_sync/constants/app_colors.dart'; // Ensure path is correct

class CustomButton {
  // --- GOOGLE SIGN IN BUTTON ---
  static Widget gogalButton({required VoidCallback onPressed, required BuildContext context}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed, 
        style: ElevatedButton.styleFrom(
          // FIXED: Background color now shifts with the theme mode natively
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: BorderSide(
              // FIXED: Adapts border color for contrast accuracy
              color: isDark ? AppColors.darkInputFill : Colors.grey.shade300,
            ),
          ),
          shadowColor: Colors.black.withOpacity(0.04),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.g_mobiledata, 
              // FIXED: Matches standard typography colors dynamically
              color: Theme.of(context).colorScheme.onSurface, 
              size: 32,
            ),
            const SizedBox(width: 8),
            Text(
              "Continue with Google",
              style: TextStyle(
                // FIXED: Text flips from dark slate to crisp white automatically
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 15,
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
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            // Premium linear gradients stay radiant and identical across both layouts
            gradient: const LinearGradient(
              colors: [Color(0xFF0052FF), Color(0xFF00D1FF)],
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white, // Text stays white on vibrant gradient layers
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}