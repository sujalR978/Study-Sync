import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void dispose() {
    username.dispose();
    phone.dispose();
    super.dispose();
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

            child: Column(
              children: [
                const SizedBox(height: 30),

                /// LOGO
                Container(
                  height: 95,
                  width: 95,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    gradient: const LinearGradient(
                      colors: [Color(0xFF0052FF), Color(0xFF00D1FF)],
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D1FF).withOpacity(0.30),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 45,
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Complete Your Profile",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Just a few more details before entering StudySync.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 15,
                    height: 1.5,
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

                  child: Form(
                    key: keyForm,

                    child: Column(
                      children: [
                        /// USERNAME
                        TextFormField(
                          controller: username,

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter username';
                            }
                            return null;
                          },

                          decoration: InputDecoration(
                            hintText: 'Username',

                            prefixIcon: const Icon(
                              Icons.person_outline,
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

                        const SizedBox(height: 18),

                        /// PHONE
                        TextFormField(
                          controller: phone,

                          keyboardType: TextInputType.phone,

                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter phone number';
                            }

                            if (value.length != 10) {
                              return 'Enter valid 10 digit number';
                            }

                            return null;
                          },

                          decoration: InputDecoration(
                            hintText: 'Phone Number',

                            prefixIcon: const Icon(
                              Icons.phone_outlined,
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

                        const SizedBox(height: 22),

                        /// REMEMBER ME
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),

                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                          ),

                          child: Row(
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
                                "Remember Me",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        /// CONTINUE BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 58,

                          child: ElevatedButton(
                            onPressed: saveData,

                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              elevation: 0,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),

                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),

                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0052FF),
                                    Color(0xFF00D1FF),
                                  ],
                                ),
                              ),

                              child: const Center(
                                child: Text(
                                  "Continue",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
