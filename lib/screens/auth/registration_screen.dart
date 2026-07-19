import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:study_sync/screens/auth/login_screen.dart';
import 'package:study_sync/services/auth_service.dart';
import 'package:study_sync/widgets/custom_button.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool rememberMe = false;
  bool isPasswordVisible = false;
  bool isCPasswordVisible = false;
  bool isLoading = false;

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

  InputDecoration _lucidInputDecoration(
    BuildContext context,
    String hint,
    IconData icon,
    Color inputFill,
    Color textBodyColor,
    Color primaryColor,
    {Widget? suffixIcon}
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: textBodyColor.withOpacity(0.4),
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      prefixIcon: Icon(
        icon,
        color: textBodyColor.withOpacity(0.7),
        size: 22,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: inputFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white.withOpacity(0.02) 
              : Colors.black.withOpacity(0.01),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 12),
    );
  }

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
          // Dynamic Glowing Accent Emitters
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              height: 280,
              width: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryAccent.withOpacity(0.12),
                boxShadow: [
                  BoxShadow(
                    color: primaryAccent.withOpacity(0.15),
                    blurRadius: 55,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
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
                    spreadRadius: 10,
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

                      Text(
                        "StudySync",
                        style: TextStyle(
                          color: onSurfaceColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Create your productivity hub",
                        style: TextStyle(
                          color: dynamicTextBody,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 36),

                      /// --- REGISTRATION SHEET WRAPPED IN FROSTED GLASS ---
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
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "ACCOUNT CREATION",
                                    style: TextStyle(
                                      color: primaryAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  /// FULL NAME
                                  TextFormField(
                                    controller: fullname,
                                    style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w600, fontSize: 15),
                                    validator: (value) => (value == null || value.isEmpty) ? 'Enter your name.' : null,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
                                    decoration: _lucidInputDecoration(context, 'Full Name', Icons.person_outline_rounded, dynamicInputFill, dynamicTextBody, primaryAccent),
                                  ),
                                  const SizedBox(height: 18),

                                  /// USERNAME
                                  TextFormField(
                                    controller: username,
                                    style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w600, fontSize: 15),
                                    validator: (value) => (value == null || value.isEmpty) ? 'Set Username.' : null,
                                    decoration: _lucidInputDecoration(context, 'Username', Icons.alternate_email_rounded, dynamicInputFill, dynamicTextBody, primaryAccent),
                                  ),
                                  const SizedBox(height: 18),

                                  /// EMAIL
                                  TextFormField(
                                    controller: email,
                                    style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w600, fontSize: 15),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Enter your email.';
                                      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                      if (!emailRegex.hasMatch(value)) return 'Enter a valid email address.';
                                      return null;
                                    },
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9@.]'))],
                                    decoration: _lucidInputDecoration(context, 'Email Address', Icons.mail_outline_rounded, dynamicInputFill, dynamicTextBody, primaryAccent),
                                  ),
                                  const SizedBox(height: 18),

                                  /// PHONE
                                  TextFormField(
                                    controller: phone,
                                    keyboardType: TextInputType.phone,
                                    style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w600, fontSize: 15),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Enter your phone.';
                                      if (value.length != 10) return 'Enter 10 digits';
                                      return null;
                                    },
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                    decoration: _lucidInputDecoration(context, 'Phone Number', Icons.phone_iphone_rounded, dynamicInputFill, dynamicTextBody, primaryAccent),
                                  ),
                                  const SizedBox(height: 18),

                                  /// PASSWORD
                                  TextFormField(
                                    controller: password,
                                    obscureText: !isPasswordVisible,
                                    style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w600, fontSize: 15),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Enter password.';
                                      if (value.length < 7) return 'Minimum 7 characters.';
                                      return null;
                                    },
                                    decoration: _lucidInputDecoration(
                                      context, 'Password', Icons.lock_outline_rounded, dynamicInputFill, dynamicTextBody, primaryAccent,
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                                        icon: Icon(isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: dynamicTextBody, size: 20),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  /// CONFIRM PASSWORD
                                  TextFormField(
                                    controller: Cpassword,
                                    obscureText: !isCPasswordVisible,
                                    style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w600, fontSize: 15),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Confirm password';
                                      if (value != password.text) return 'Passwords do not match';
                                      return null;
                                    },
                                    decoration: _lucidInputDecoration(
                                      context, 'Confirm Password', Icons.lock_outline_rounded, dynamicInputFill, dynamicTextBody, primaryAccent,
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(() => isCPasswordVisible = !isCPasswordVisible),
                                        icon: Icon(isCPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: dynamicTextBody, size: 20),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  /// TERMS AND CONDITIONS
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(50, 30),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          "Terms & Conditions",
                                          style: TextStyle(
                                            color: primaryAccent,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  /// CREATE ACCOUNT BUTTON TRIGGER
                                  CustomButton.loginButton(
                                    text: 'Create Account',
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() => isLoading = true);
                                        
                                        final AuthService registerService = AuthService();
                                        await registerService.registerUser(
                                          fullname: fullname.text.trim(),
                                          username: username.text.trim(),
                                          email: email.text.trim(),
                                          phone: phone.text.trim(),
                                          password: password.text.trim(),
                                        );

                                        if (!mounted) return;
                                        setState(() => isLoading = false);
                                        
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
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
                            style: TextStyle(color: dynamicTextBody, fontWeight: FontWeight.w600),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: Text(
                              "Log In",
                              style: TextStyle(color: primaryAccent, fontWeight: FontWeight.w800),
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
                                "Building Workspace...",
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