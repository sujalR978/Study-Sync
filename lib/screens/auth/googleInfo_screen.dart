import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_sync/models/user_model.dart';
import 'package:study_sync/providers/auth_provider.dart';
import 'package:study_sync/screens/home/home_screen.dart';
import 'package:study_sync/services/auth_service.dart';

class GoogleInfoScreen extends StatefulWidget {
  const GoogleInfoScreen({super.key}); 

  @override
  State<GoogleInfoScreen> createState() => _GoogleInfoScreenState();
}

class _GoogleInfoScreenState extends State<GoogleInfoScreen> {
  final GlobalKey<FormState> keyForm = GlobalKey<FormState>();

  final TextEditingController username = TextEditingController();
  final TextEditingController phone = TextEditingController();

  bool rememberMe = false;
  bool _isContinuePressed = false;

  @override
  void dispose() {
    username.dispose();
    phone.dispose();
    super.dispose();
  }

  Future<void> loadUser() async {
    if (FirebaseAuth.instance.currentUser != null) {
      UserModel? userData = await AuthService().getCurrentUserData();
      if (userData != null) {
        context.read<Authprovider>().setUser(userData);
      }
    }
  }

  Future<void> saveData() async {
    if (!keyForm.currentState!.validate()) return;

    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('logIn', rememberMe);

    AuthService auth = AuthService();
    await auth.googleUser(
      username: username.text.trim(),
      phone: phone.text.trim(),
    );

    if (!mounted) return;
    await loadUser();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  InputDecoration _lucidInputDecoration(
    BuildContext context,
    String hint,
    IconData icon,
    Color inputFill,
    Color textBodyColor,
    Color primaryColor,
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

    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color onSurfaceColor = theme.colorScheme.onSurface;
    final Color surfaceColor = theme.colorScheme.surface;

    final Color dynamicTextBody = onSurfaceColor.withOpacity(0.55);
    final Color dynamicInputFill = Color.alphaBlend(
      primaryColor.withOpacity(isDark ? 0.12 : 0.06),
      surfaceColor,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Ambient Onboarding Ambient Glow Emitters
          Positioned(
            top: -40,
            left: -50,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.08),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.08),
                    blurRadius: 65,
                    spreadRadius: 0,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor.withOpacity(0.06),
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withOpacity(0.06),
                    blurRadius: 70,
                    spreadRadius: 0,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// UPGRADED THEME-REACTIVE GRADIENT LOGO Frame
                    Container(
                      height: 95,
                      width: 95,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primaryColor, secondaryColor],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.30),
                            blurRadius: 30,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      "Complete Your Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: onSurfaceColor,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Just a few more details before entering StudySync.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: dynamicTextBody,
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 36),

                    /// --- DATA REGISTRY PANEL ENCLOSED IN FROSTED ACRYLIC MESH ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: surfaceColor.withOpacity(isDark ? 0.30 : 0.45),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                              width: 1.5,
                            ),
                          ),
                          child: Form(
                            key: keyForm,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ACCOUNT ACCESS INITIALIZATION",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                /// USERNAME FORM FIELD
                                TextFormField(
                                  controller: username,
                                  style: TextStyle(
                                    color: onSurfaceColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  validator: (value) => (value == null || value.isEmpty) ? 'Enter username' : null,
                                  decoration: _lucidInputDecoration(
                                    context, 'Username', Icons.person_outline_rounded,
                                    dynamicInputFill, dynamicTextBody, primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 18),

                                /// PHONE NUMBER FORM FIELD
                                TextFormField(
                                  controller: phone,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(
                                    color: onSurfaceColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Enter phone number';
                                    if (value.length != 10) return 'Enter valid 10 digit number';
                                    return null;
                                  },
                                  decoration: _lucidInputDecoration(
                                    context, 'Phone Number', Icons.phone_iphone_rounded,
                                    dynamicInputFill, dynamicTextBody, primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 22),

                                /// REMEMBER ME SELECTION TRACK
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: dynamicInputFill.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: rememberMe,
                                        activeColor: primaryColor,
                                        side: BorderSide(
                                          color: onSurfaceColor.withOpacity(0.4),
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                        onChanged: (value) => setState(() => rememberMe = value!),
                                      ),
                                      Text(
                                        "Remember Me",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: onSurfaceColor.withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),

                                /// THEME-REACTIVE ANIMATED CONTINUE BUTTON
                                GestureDetector(
                                  onTapDown: (_) => setState(() => _isContinuePressed = true),
                                  onTapUp: (_) => setState(() => _isContinuePressed = false),
                                  onTapCancel: () => setState(() => _isContinuePressed = false),
                                  onTap: saveData,
                                  child: AnimatedScale(
                                    scale: _isContinuePressed ? 0.96 : 1.0,
                                    duration: const Duration(milliseconds: 120),
                                    curve: Curves.easeOutCubic,
                                    child: Container(
                                      width: double.infinity,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [primaryColor, secondaryColor],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryColor.withOpacity(0.35),
                                            blurRadius: 18,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Continue Setup",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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