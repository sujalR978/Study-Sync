import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_sync/models/user_model.dart';
import 'package:study_sync/providers/auth_provider.dart';
import 'package:study_sync/screens/BottomNavigation.dart';
import 'package:study_sync/screens/auth/googleInfo_screen.dart';
import 'package:study_sync/screens/auth/rememberMe_screen.dart';
import 'package:study_sync/services/auth_service.dart';
import 'package:study_sync/widgets/custom_button.dart';
import 'package:study_sync/widgets/custom_textfield.dart';
import 'package:study_sync/screens/auth/registration_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordVisible = false;
  bool rememberMe = false;
  bool isLoading = false;

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color surfaceColor = theme.colorScheme.surface;
    final Color onSurfaceColor = theme.colorScheme.onSurface;
    final Color primaryAccent = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;

    final Color dynamicInputFill = Color.alphaBlend(
      primaryAccent.withOpacity(isDark ? 0.12 : 0.06),
      surfaceColor,
    );

    final Color dynamicTextBody = onSurfaceColor.withOpacity(0.55);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Dynamic Ambient Backlight Emitters
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              height: 280,
              width: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryAccent.withOpacity(0.12),
                boxShadow: [
                  BoxShadow(
                    color: primaryAccent.withOpacity(0.14),
                    blurRadius: 55,
                    spreadRadius: 12,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor.withOpacity(0.08),
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withOpacity(0.12),
                    blurRadius: 60,
                    spreadRadius: 14,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 750),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1.0 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      // Modern Rounded Glowing App Logo Frame
                      Container(
                        height: 90,
                        width: 95,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primaryAccent, secondaryColor],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryAccent.withOpacity(0.3),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 24),

                      customText.titalText('Study Sync', context: context),
                      const SizedBox(height: 10),
                      Text(
                        "Welcome back",
                        style: TextStyle(
                          color: onSurfaceColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      customText.opacityText('Stay focused and productive', context: context),
                      const SizedBox(height: 36),

                      // --- MODULE ACCESS SHEET WRAPPED IN FROSTED GLASS ---
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.all(26),
                            decoration: BoxDecoration(
                              color: surfaceColor.withOpacity(isDark ? 0.30 : 0.45),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? Colors.black38 : Colors.grey.withOpacity(0.05),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "EMAIL ADDRESS",
                                        style: TextStyle(
                                          color: primaryAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: email,
                                        style: TextStyle(
                                          color: onSurfaceColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                        validator: (value) => (value == null || value.isEmpty) ? 'Email is empty.' : null,
                                        decoration: InputDecoration(
                                          hintText: "name@example.com",
                                          hintStyle: TextStyle(
                                            color: onSurfaceColor.withOpacity(0.3),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.mail_outline_rounded,
                                            color: dynamicTextBody,
                                            size: 22,
                                          ),
                                          filled: true,
                                          fillColor: dynamicInputFill,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide(
                                              color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01),
                                              width: 1.5,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide(
                                              color: primaryAccent,
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "PASSWORD",
                                            style: TextStyle(
                                              color: primaryAccent,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {},
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(50, 30),
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: Text(
                                              "Forgot Password?",
                                              style: TextStyle(
                                                color: primaryAccent,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: password,
                                        style: TextStyle(
                                          color: onSurfaceColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                        validator: (value) => (value == null || value.isEmpty) ? 'Password is empty.' : null,
                                        obscureText: !isPasswordVisible,
                                        decoration: InputDecoration(
                                          hintText: "••••••••",
                                          hintStyle: TextStyle(
                                            color: onSurfaceColor.withOpacity(0.3),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.lock_outline_rounded,
                                            color: dynamicTextBody,
                                            size: 22,
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                                            icon: Icon(
                                              isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                              color: dynamicTextBody,
                                              size: 20,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: dynamicInputFill,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide(
                                              color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01),
                                              width: 1.5,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide(
                                              color: primaryAccent,
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),

                                InkWell(
                                  onTap: () => setState(() => rememberMe = !rememberMe),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: rememberMe,
                                            activeColor: primaryAccent,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                            side: BorderSide(
                                              color: onSurfaceColor.withOpacity(0.4),
                                              width: 1.5,
                                            ),
                                            onChanged: (value) => setState(() => rememberMe = value!),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "Remember me for 30 days",
                                          style: TextStyle(
                                            color: onSurfaceColor.withOpacity(0.8),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),

                                CustomButton.loginButton(
                                  text: 'Log In',
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() => isLoading = true);

                                      final SharedPreferences sp = await SharedPreferences.getInstance();
                                      sp.setBool('logIn', rememberMe);

                                      AuthService login = AuthService();
                                      final error = await login.loginUser(
                                        email: email.text.trim(),
                                        password: password.text.trim(),
                                      );

                                      if (!mounted) return;
                                      setState(() => isLoading = false);

                                      if (error == null) {
                                        UserModel? userData = await AuthService().getCurrentUserData();
                                        if (userData != null) {
                                          context.read<Authprovider>().setUser(userData);
                                        }
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(builder: (context) => const Bottomnavigation()),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(error)),
                                        );
                                      }
                                    }
                                  },
                                ),
                                const SizedBox(height: 28),

                                Row(
                                  children: [
                                    Expanded(child: Divider(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        "OR CONTINUE WITH",
                                        style: TextStyle(
                                          color: onSurfaceColor.withOpacity(0.35),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04))),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                CustomButton.gogalButton(
                                  context: context,
                                  onPressed: () async {
                                    setState(() => isLoading = true);

                                    AuthService auth = AuthService();
                                    final logIn = await auth.googleSingIn();

                                    if (!mounted) return;
                                    setState(() => isLoading = false);

                                    if (logIn == null) {
                                      UserModel? userData = await AuthService().getCurrentUserData();
                                      if (userData != null) {
                                        context.read<Authprovider>().setUser(userData);
                                      }

                                      User? US = FirebaseAuth.instance.currentUser;
                                      String uid = US!.uid;
                                      DocumentSnapshot doc = await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(uid)
                                          .get();

                                      if (!doc.exists) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (_) => const GoogleInfoScreen()),
                                        );
                                      } else {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (_) => const RememberMeScreen()),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(logIn.toString())),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: dynamicTextBody,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const RegisterScreen()),
                              );
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: primaryAccent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Custom High-Fidelity Loading Blur Overlay
          if (isLoading)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 250),
              builder: (context, val, child) {
                return Opacity(
                  opacity: val,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                        color: isDark ? Colors.black87 : Colors.white.withOpacity(0.5),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: primaryAccent,
                                strokeWidth: 3.5,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Securing your session...",
                                style: TextStyle(
                                  color: onSurfaceColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  letterSpacing: -0.2,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}