import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:study_sync/screens/auth/login_screen.dart';
import 'package:study_sync/widgets/custom_button.dart';
import 'package:study_sync/widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool rememberMe = false;

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

                /// TITLE
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

                /// CARD
                Container(
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
                        hintText: 'Full Name',

                        icon: Icons.person_outline,

                        valideter: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your name.';
                          }

                          return null;
                        },

                        regex: [
                          FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// USERNAME
                      CustomTextfield.customTextField(
                        hintText: "Username",

                        icon: Icons.alternate_email,
                      ),

                      const SizedBox(height: 18),

                      /// EMAIL
                      CustomTextfield.customTextField(
                        hintText: "Email Address",

                        icon: Icons.mail_outline,
                      ),

                      const SizedBox(height: 18),

                      /// PHONE
                      CustomTextfield.customTextField(
                        hintText: "Phone Number",

                        icon: Icons.phone_outlined,
                      ),

                      const SizedBox(height: 18),

                      /// PASSWORD
                      CustomTextfield.customTextField(
                        hintText: "Password",

                        icon: Icons.lock_outline,

                        obscureText: true,

                        suffixIcon: const Icon(
                          Icons.visibility_off,

                          color: Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// CONFIRM PASSWORD
                      CustomTextfield.customTextField(
                        hintText: "Confirm Password",

                        icon: Icons.lock_outline,

                        obscureText: true,

                        suffixIcon: const Icon(
                          Icons.visibility_off,

                          color: Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// REMEMBER + TERMS
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,

                            onChanged: (value) {
                              setState(() {
                                rememberMe = value!;
                              });
                            },

                            activeColor: const Color(0xFF0052FF),
                          ),

                          const Text(
                            "Remember Me",

                            style: TextStyle(
                              color: Color(0xFF64748B),

                              fontWeight: FontWeight.w500,
                            ),
                          ),

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

                        onPressed: () {},
                      ),

                      const SizedBox(height: 28),

                      /// DIVIDER
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),

                            child: Text(
                              "OR",

                              style: TextStyle(
                                color: Colors.grey.shade500,

                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),

                      const SizedBox(height: 28),

                      /// GOOGLE BUTTON
                      CustomButton.gogalButton(),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// LOGIN
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
