import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_sync/screens/home/home_screen.dart';
import 'package:study_sync/services/auth_service.dart';

class CustomButton {
  static gogalButton({required VoidCallback onPressed}) {
    return Container(
      height: 56,
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(50),

        border: Border.all(color: Colors.grey.shade300),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: const [
            Icon(Icons.g_mobiledata, color: Color(0xFF0F172A), size: 32),

            SizedBox(width: 8),

            Text(
              "Continue with Google",

              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            gradient: const LinearGradient(
              colors: [Color(0xFF0052FF), Color(0xFF00D1FF)],
            ),

            borderRadius: BorderRadius.circular(50),
          ),

          child: Container(
            alignment: Alignment.center,

            child: Text(
              text,

              style: TextStyle(
                color: Colors.white,
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
