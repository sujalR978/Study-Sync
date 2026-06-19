import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
import 'package:study_sync/constants/app_colors.dart'; // Ensure path is correct

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordVisible = false;
  bool  rememberMe = false;
  bool isLoading = false;

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // FIXED: Dynamic structural scaffolding background layout
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          /// TOP BLUE GLOW
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0052FF).withOpacity(0.06),
              ),
            ),
          ),

          /// BOTTOM CYAN GLOW
          Positioned(
            bottom: -140,
            right: -140,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00D1FF).withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    /// LOGO
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0052FF), Color(0xFF00D1FF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0052FF).withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// APP NAME
                    customText.titalText('Study Sync'),

                    const SizedBox(height: 12),

                    Text(
                      "Welcome back",
                      style: TextStyle(
                        // FIXED: Theme-aware headers configuration
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    customText.opacityText('Stay focused and productive'),

                    const SizedBox(height: 40),

                    /// LOGIN CARD
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        // FIXED: Surface card layer colors updates automatically
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black38
                                : Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          /// EMAIL FIELD
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "EMAIL ADDRESS",
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTextBody
                                        : AppColors.textBody,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: email,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is empty.';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: "name@example.com",
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? AppColors.darkTextBody.withOpacity(
                                              0.6,
                                            )
                                          : const Color(0xFF94A3B8),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.mail_outline,
                                      color: isDark
                                          ? AppColors.darkTextBody
                                          : AppColors.textBody,
                                    ),
                                    filled: true,
                                    // FIXED: Container field backgrounds tracking configuration
                                    fillColor: isDark
                                        ? AppColors.darkInputFill
                                        : AppColors.inputFill,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF00D1FF),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                /// PASSWORD LABEL
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "PASSWORD",
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.darkTextBody
                                            : AppColors.textBody,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                          color: Color(0xFF0052FF),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                /// PASSWORD FIELD
                                TextFormField(
                                  controller: password,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is empty.';
                                    }
                                    return null;
                                  },
                                  obscureText: !isPasswordVisible,
                                  decoration: InputDecoration(
                                    hintText: "••••••••",
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? AppColors.darkTextBody.withOpacity(
                                              0.6,
                                            )
                                          : const Color(0xFF94A3B8),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: isDark
                                          ? AppColors.darkTextBody
                                          : AppColors.textBody,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isPasswordVisible =
                                              !isPasswordVisible;
                                        });
                                      },
                                      icon: Icon(
                                        isPasswordVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: isDark
                                            ? AppColors.darkTextBody
                                            : AppColors.textBody,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: isDark
                                        ? AppColors.darkInputFill
                                        : AppColors.inputFill,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF00D1FF),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// REMEMBER ME
                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                activeColor: const Color(0xFF0052FF),
                                side: BorderSide(
                                  color: isDark
                                      ? AppColors.darkTextBody
                                      : AppColors.textBody,
                                  width: 1.5,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    rememberMe = value!;
                                  });
                                },
                              ),
                              Text(
                                "Remember me for 30 days",
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkTextBody
                                      : AppColors.textBody,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          /// LOGIN BUTTON
                          CustomButton.loginButton(
                            text: 'Log In',
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });

                                final SharedPreferences sp =
                                    await SharedPreferences.getInstance();
                                sp.setBool('logIn', rememberMe);

                                AuthService login = AuthService();
                                final error = await login.loginUser(
                                  email: email.text.trim(),
                                  password: password.text.trim(),
                                );

                                if (!mounted) return;

                                setState(() {
                                  isLoading = false;
                                });

                                if (error == null) {
                                  UserModel? userData = await AuthService()
                                      .getCurrentUserData();

                                  if (userData != null) {
                                    context.read<Authprovider>().setUser(
                                      userData,
                                    );
                                  }
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const Bottomnavigation(),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error)),
                                  );
                                }
                              }
                            },
                          ),

                          const SizedBox(height: 32),

                          /// DIVIDER
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? AppColors.darkInputFill
                                      : Colors.grey.shade300,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  "OR",
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTextBody
                                        : Colors.grey.shade500,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? AppColors.darkInputFill
                                      : Colors.grey.shade300,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          /// GOOGLE BUTTON
                          CustomButton.gogalButton(
                            context: context,
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });

                              AuthService auth = AuthService();
                              final logIn = await auth.googleSingIn();

                              if (!mounted) return;

                              setState(() {
                                isLoading = false;
                              });

                              if (logIn == null) {
                                UserModel? userData = await AuthService()
                                    .getCurrentUserData();

                                if (userData != null) {
                                  context.read<Authprovider>().setUser(
                                    userData,
                                  );
                                }

                                User? US = FirebaseAuth.instance.currentUser;
                                String uid = US!.uid;
                                DocumentSnapshot doc = await FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .doc(uid)
                                    .get();

                                if (!doc.exists) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const GoogleInfoScreen(),
                                    ),
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RememberMeScreen(),
                                    ),
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

                    const SizedBox(height: 30),

                    /// SIGN UP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextBody
                                : AppColors.textBody,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Color(0xFF0052FF),
                              fontWeight: FontWeight.w700,
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

          /// --- NEW: ADAPTIVE LOADING OVERLAY ---
          if (isLoading)
            Container(
              // FIXED: Adapts contrast screen dim transparency properties
              color: isDark ? Colors.black54 : Colors.white.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF0052FF)),
              ),
            ),
        ],
      ),
    );
  }
}
