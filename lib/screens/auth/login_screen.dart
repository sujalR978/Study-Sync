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
import 'package:study_sync/constants/app_colors.dart';

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

    // Dynamic color tokens linked automatically to the selected active theme
    final Color surfaceColor = theme.colorScheme.surface;
    final Color onSurfaceColor = theme.colorScheme.onSurface;
    final Color primaryAccent = theme.colorScheme.primary;

    // Resolving matching input fill colors based on background brightness
    final Color dynamicInputFill = isDark 
        ? (surfaceColor == AppColors.crimsonSurface ? AppColors.crimsonInputFill : AppColors.darkInputFill)
        : (surfaceColor == AppColors.mintSurface ? AppColors.mintInputFill : AppColors.inputFill);

    final Color dynamicTextBody = isDark 
        ? (surfaceColor == AppColors.crimsonSurface ? AppColors.crimsonNeutral.withOpacity(0.7) : AppColors.darkTextBody)
        : (surfaceColor == AppColors.mintSurface ? AppColors.mintNeutral.withOpacity(0.7) : AppColors.textBody);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Dynamic Glowing Accent Orbs (Colors map cleanly to active themes)
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryAccent.withOpacity(0.12),
                boxShadow: [
                  BoxShadow(
                    color: primaryAccent.withOpacity(0.12),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -50,
            child: Container(
              height: 320,
              width: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withOpacity(0.08),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.secondary.withOpacity(0.08),
                    blurRadius: 50,
                    spreadRadius: 12,
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
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1.0 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      // Modern Rounded Glowing App Logo
                      Container(
                        height: 95,
                        width: 95,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primaryAccent, theme.colorScheme.secondary],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryAccent.withOpacity(0.3),
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // FIXED: Swapped parameter positions to match your signature setup cleanly
                      customText.titalText('Study Sync', context: context),
                      const SizedBox(height: 8),
                      Text(
                        "Welcome back",
                        style: TextStyle(
                          color: onSurfaceColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      customText.opacityText('Stay focused and productive', context: context),
                      const SizedBox(height: 36),

                      // Refactored Container Card with Premium Lighting Details
                      Container(
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black54 : Colors.grey.withOpacity(0.12),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
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
                                      color: dynamicTextBody,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: email,
                                    style: TextStyle(
                                      color: onSurfaceColor,
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
                                        color: dynamicTextBody.withOpacity(0.5),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.mail_outline_rounded,
                                        color: dynamicTextBody,
                                      ),
                                      filled: true,
                                      fillColor: dynamicInputFill,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
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
                                          color: dynamicTextBody,
                                          fontSize: 11,
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
                                            fontWeight: FontWeight.w700,
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
                                        color: dynamicTextBody.withOpacity(0.5),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock_outline_rounded,
                                        color: dynamicTextBody,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isPasswordVisible = !isPasswordVisible;
                                          });
                                        },
                                        icon: Icon(
                                          isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                          color: dynamicTextBody,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: dynamicInputFill,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
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
                            const SizedBox(height: 16),

                            InkWell(
                              onTap: () {
                                setState(() {
                                  rememberMe = !rememberMe;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
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
                                        color: dynamicTextBody,
                                        width: 1.5,
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          rememberMe = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Remember me for 30 days",
                                    style: TextStyle(
                                      color: dynamicTextBody,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Log In Business Logic Trigger Block
                            CustomButton.loginButton(
                              text: 'Log In',
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  final SharedPreferences sp = await SharedPreferences.getInstance();
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
                                    UserModel? userData = await AuthService().getCurrentUserData();

                                    if (userData != null) {
                                      context.read<Authprovider>().setUser(userData);
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
                            const SizedBox(height: 28),

                            Row(
                              children: [
                                Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.grey.shade300)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    "OR CONTINUE WITH",
                                    style: TextStyle(
                                      color: dynamicTextBody.withOpacity(0.6),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.grey.shade300)),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Google SignIn Business Logic Trigger Block
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
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: dynamicTextBody,
                              fontWeight: FontWeight.w500,
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

          // Custom High-Fidelity Loading View Overlay
          if (isLoading)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 250),
              builder: (context, val, child) {
                return Opacity(
                  opacity: val,
                  child: Container(
                    color: isDark ? Colors.black87 : Colors.white.withOpacity(0.7),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: primaryAccent,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Securing your session...",
                            style: TextStyle(
                              color: onSurfaceColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          )
                        ],
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