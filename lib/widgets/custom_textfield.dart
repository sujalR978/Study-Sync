import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_sync/constants/app_colors.dart'; 

class customText {
  static Widget titalText(String text, {BuildContext? context}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
      
        color: context != null
            ? Theme.of(context).colorScheme.onBackground
            : null,
      ),
    );
  }

  static Widget opacityText(String text, {BuildContext? context}) {
    Color? fallbackColor; 
    if (context != null) {
      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      fallbackColor = isDark ? AppColors.darkTextBody : AppColors.textBody;
    }

    return Opacity(
      opacity: 0.6,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color:
              fallbackColor, 
        ),
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
    required BuildContext
    context,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: valideter,
      inputFormatters: regex,
      style: TextStyle(
       
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark
              ? AppColors.darkTextBody.withOpacity(0.6)
              : const Color(0xFF94A3B8),
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? AppColors.darkTextBody : const Color(0xFF64748B),
        ),
        suffixIcon: suffixIcon,
        filled: true,
      
        fillColor: isDark ? AppColors.darkInputFill : const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF00D1FF), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
