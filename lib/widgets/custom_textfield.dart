import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class customText {
  static titalText(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
    );
  }

  static opacityText(String text) {
    return Opacity(
      opacity: 0.6,
      child: Text(text, style: TextStyle(fontSize: 16)),
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
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: valideter,
      inputFormatters: regex,

      decoration: InputDecoration(
        hintText: hintText,

        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),

        prefixIcon: Icon(icon, color: const Color(0xFF64748B)),

        suffixIcon: suffixIcon,

        filled: true,

        fillColor: const Color(0xFFF8FAFC),

        contentPadding: const EdgeInsets.symmetric(vertical: 18),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),

          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),

          borderSide: const BorderSide(color: Color(0xFF00D1FF), width: 1.5),
        ),
      ),
    );
  }
}
