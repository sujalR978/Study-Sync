import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_sync/screens/home/home_screen.dart';

class RememberMeScreen extends StatefulWidget {
  const RememberMeScreen({super.key});

  @override
  State<RememberMeScreen> createState() => _RememberMeScreenState();
}

class _RememberMeScreenState extends State<RememberMeScreen> {
  bool rememberMe = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Center(
            child: Container(
              padding: const EdgeInsets.all(28),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),

                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
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
                          color: const Color(0xFF00D1FF).withOpacity(0.3),
                          blurRadius: 25,
                          spreadRadius: 3,
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons.security_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Stay Logged In?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Keep your account signed in for faster access to your study sessions and tasks.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
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

                        const Expanded(
                          child: Text(
                            "Remember me on this device",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton(
                      onPressed: () async {
                        // Save preference here
                        SharedPreferences spset =
                            await SharedPreferences.getInstance();

                        spset.setBool('logIn', rememberMe);

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),

                        padding: EdgeInsets.zero,
                      ),

                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),

                          gradient: const LinearGradient(
                            colors: [Color(0xFF0052FF), Color(0xFF00D1FF)],
                          ),
                        ),

                        child: const Center(
                          child: Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
