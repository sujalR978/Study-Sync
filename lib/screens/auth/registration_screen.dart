import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_sync/screens/auth/login_screen.dart';
import 'package:study_sync/services/auth_service.dart';
import 'package:study_sync/widgets/custom_button.dart';
import 'package:study_sync/widgets/custom_textfield.dart';
import 'package:study_sync/constants/app_colors.dart'; // Ensure path is correct

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool rememberMe = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController fullname = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController Cpassword = TextEditingController();

  @override
  void dispose() {
    fullname.dispose();
    username.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    Cpassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // FIXED: Dynamic structural scaffolding canvas layout mapping
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // FIXED: Adaptive ambient gradient backdrop sequence
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkBackground, AppColors.darkSurface]
                : [const Color(0xFFF8FAFF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
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
                        color: const Color(0xFF00D1FF).withOpacity(0.25),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "StudySync",
                  style: TextStyle(
                    // FIXED: Color configuration shifts dynamically
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Create your productivity hub",
                  style: TextStyle(
                    // FIXED: Dynamic text body color allocation
                    color: isDark
                        ? AppColors.darkTextBody
                        : const Color(0xFF64748B),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 35),

                /// FORM WRAPPER
                Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      // FIXED: Card wrapper adapts to global brightness state
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black38
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        /// FULL NAME
                        CustomTextfield.customTextField(
                          context: context,
                          controller: fullname,
                          hintText: 'Full Name',
                          icon: Icons.person_outline,
                          valideter: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter your name.';
                            }
                            return null;
                          },
                          regex: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z ]'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        /// USERNAME
                        CustomTextfield.customTextField(
                          context: context,
                          controller: username,
                          hintText: "Username",
                          icon: Icons.alternate_email,
                          valideter: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Set Username.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        /// EMAIL
                        CustomTextfield.customTextField(
                          context: context,
                          controller: email,
                          hintText: "Email Address",
                          icon: Icons.mail_outline,
                          valideter: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter your email.';
                            }
                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            );

                            if (!emailRegex.hasMatch(value)) {
                              return 'Enter a valid email address.';
                            }
                            return null;
                          },
                          regex: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-z0-9@.]'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        /// PHONE
                        CustomTextfield.customTextField(
                          controller: phone,
                          context: context,
                          hintText: "Phone Number",
                          icon: Icons.phone_outlined,
                          valideter: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter your phone.';
                            }
                            if (value.length > 10) {
                              return 'You Entered ${value.length} digits (10)';
                            }
                            if (value.length < 10) {
                              return 'You Entered ${value.length} digits (10)';
                            }
                            return null;
                          },
                          regex: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                        ),

                        const SizedBox(height: 18),

                        /// PASSWORD
                        CustomTextfield.customTextField(
                          context: context,
                          controller: password,
                          hintText: "Password",
                          icon: Icons.lock_outline,
                          obscureText: true,
                          valideter: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter password.';
                            }
                            // FIX: Logic structural bug fixed (should check if length is LESS than 7)
                            if (value.length < 7) {
                              return 'Password length must be at least 7 characters.';
                            }
                            return null;
                          },
                          suffixIcon: Icon(
                            Icons.visibility_off,
                            color: isDark
                                ? AppColors.darkTextBody
                                : const Color(0xFF64748B),
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// CONFIRM PASSWORD
                        CustomTextfield.customTextField(
                          context: context,
                          controller: Cpassword,
                          hintText: "Confirm Password",
                          icon: Icons.lock_outline,
                          obscureText: true,
                          valideter: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm password';
                            }
                            // FIX: Safely unpack and parse controller text assignments
                            if (value != password.text) {
                              return 'Confirm password does not match password';
                            }
                            return null;
                          },
                          suffixIcon: Icon(
                            Icons.visibility_off,
                            color: isDark
                                ? AppColors.darkTextBody
                                : const Color(0xFF64748B),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// TERMS AND CONDITIONS
                        Row(
                          children: [
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Terms & Conditions",
                                style: TextStyle(
                                  color: Color(0xFF00D1FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// CREATE ACCOUNT BUTTON
                        CustomButton.loginButton(
                          text: 'Create Account',
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final AuthService registerService = AuthService();

                              await registerService.registerUser(
                                fullname: fullname.text.trim(),
                                username: username.text.trim(),
                                email: email.text.trim(),
                                phone: phone.text.trim(),
                                password: password.text.trim(),
                              );

                              if (!context.mounted)
                                return; // FIXED: Prevents unsafe route pops across async barriers

                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                 ),
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// LOGIN NAVIGATION
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextBody
                            : const Color(0xFF64748B),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFF00D1FF),
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
    );
  }
}
