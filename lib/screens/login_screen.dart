import 'package:flutter/material.dart';
import 'package:study_sync/widgets/custom_button.dart';
import 'package:study_sync/widgets/custom_textfield.dart';
import 'package:study_sync/screens/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordVisible = false;
  bool rememberMe = false;

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

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

                    const Text(
                      "Welcome back",

                      style: TextStyle(
                        color: Color(0xFF0F172A),
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
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(28),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),

                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          /// EMAIL FIELD
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                "EMAIL ADDRESS",

                                style: TextStyle(
                                  color: Color(0xFF64748B),

                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,

                                  letterSpacing: 1.2,
                                ),
                              ),

                              const SizedBox(height: 10),

                              TextFormField(
                                controller: emailController,

                                decoration: InputDecoration(
                                  hintText: "name@example.com",

                                  hintStyle: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                  ),

                                  prefixIcon: const Icon(
                                    Icons.mail_outline,

                                    color: Color(0xFF64748B),
                                  ),

                                  filled: true,

                                  fillColor: const Color(0xFFF8FAFC),

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

                          const SizedBox(height: 24),

                          /// PASSWORD LABEL
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              const Text(
                                "PASSWORD",

                                style: TextStyle(
                                  color: Color(0xFF64748B),

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
                            controller: passwordController,

                            obscureText: !isPasswordVisible,

                            decoration: InputDecoration(
                              hintText: "••••••••",

                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                              ),

                              prefixIcon: const Icon(
                                Icons.lock_outline,

                                color: Color(0xFF64748B),
                              ),

                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },

                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,

                                  color: const Color(0xFF64748B),
                                ),
                              ),

                              filled: true,

                              fillColor: const Color(0xFFF8FAFC),

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

                          const SizedBox(height: 20),

                          /// REMEMBER ME
                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,

                                activeColor: const Color(0xFF0052FF),

                                onChanged: (value) {
                                  setState(() {
                                    rememberMe = value!;
                                  });
                                },
                              ),

                              const Text(
                                "Remember me for 30 days",

                                style: TextStyle(
                                  color: Color(0xFF64748B),

                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          /// LOGIN BUTTON
                          // CustomButton.LoginButton('Log In'),
                          CustomButton.loginButton(
                            text: 'Log In',
                            onPressed: () {},
                          ),

                          const SizedBox(height: 32),

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
                          CustomButton.gogalButton(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// SIGN UP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        const Text(
                          "Don't have an account?",

                          style: TextStyle(color: Color(0xFF64748B)),
                        ),

                        TextButton(
                          onPressed: () {
                            setState(() {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(),
                                ),
                              );
                            });
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
        ],
      ),
    );
  }
}
