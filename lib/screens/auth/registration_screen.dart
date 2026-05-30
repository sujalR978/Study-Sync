import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_sync/screens/auth/googleInfo_screen.dart';

import 'package:study_sync/screens/auth/login_screen.dart';
import 'package:study_sync/screens/home/home_screen.dart';
import 'package:study_sync/services/auth_service.dart';
import 'package:study_sync/widgets/custom_button.dart';
import 'package:study_sync/widgets/custom_textfield.dart';

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
    // TODO: implement dispose
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFF), Colors.white],
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

                const Text(
                  "StudySync",
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Create your productivity hub",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 35),

                /// FORM WRAPPER (IMPORTANT)
                Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        /// FULL NAME
                        CustomTextfield.customTextField(
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
                          hintText: "Phone Number",
                          icon: Icons.phone_outlined,
                          valideter: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter your phone.';
                            }
                            if (value.length > 10) {
                              return 'You Enter ' +
                                  value.length.toString() +
                                  'digit (10)';
                            }
                            if (value.length < 10) {
                              return 'You Enter ' +
                                  value.length.toString() +
                                  ' digit (10)';
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
                          controller: password,
                          hintText: "Password",
                          icon: Icons.lock_outline,
                          obscureText: true,
                          valideter: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter password.';
                            }
                            if (value.length > 7) {
                              return 'password length must be 7';
                            }
                            return null;
                          },
                          suffixIcon: const Icon(
                            Icons.visibility_off,
                            color: Color(0xFF64748B),
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// CONFIRM PASSWORD
                        CustomTextfield.customTextField(
                          controller: Cpassword,
                          hintText: "Confirm Password",
                          icon: Icons.lock_outline,
                          obscureText: true,
                          valideter: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm password';
                            }
                            if (value == password) {
                              return 'confirm password is not match with password';
                            }
                            return null;
                          },
                          suffixIcon: const Icon(
                            Icons.visibility_off,
                            color: Color(0xFF64748B),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// CHECKBOX
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

                        /// CREATE ACCOUNT BUTTON (FORM VALIDATION ADDED)
                        CustomButton.loginButton(
                          text: 'Create Account',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // All fields are valid

                              final AuthService _register = AuthService();
                              _register.registerUser(
                                fullname: fullname.text.trim(),
                                username: username.text.trim(),
                                email: email.text.trim(),
                                phone: phone.text.trim(),
                                password: password.text.trim(),
                              );
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 28),

                        /// DIVIDER
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        /// GOOGLE BUTTON
                        CustomButton.gogalButton(
                           onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                AuthService login = AuthService();
                                final error = await login.loginUser(
                                  email: email.text.trim(),
                                  password: password.text.trim(),
                                );
                                if (!mounted) return;

                                if (error == null) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => googleInfoscreen(),
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
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// LOGIN NAVIGATION
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(color: Color(0xFF64748B)),
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
