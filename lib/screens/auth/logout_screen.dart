import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_sync/providers/auth_provider.dart';
import 'package:study_sync/screens/auth/login_screen.dart';
import 'package:study_sync/screens/home/home_screen.dart';
import 'package:study_sync/screens/profile/profileScreen.dart';
import 'package:study_sync/services/auth_service.dart';
import 'package:study_sync/widgets/custom_button.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  // --- NEW: Loading state variable ---
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFF), Color(0xFFFFFFFF)],
          ),
        ),
        child: Stack(
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
                  color: const Color(0xFF0052FF).withOpacity(0.08),
                ),
              ),
            ),

            /// BOTTOM CYAN GLOW
            Positioned(
              bottom: -120,
              right: -120,
              child: Container(
                height: 280,
                width: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00D1FF).withOpacity(0.08),
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// LOGOUT CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),

                        child: Column(
                          children: [
                            /// ICON
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0052FF),
                                    Color(0xFF00D1FF),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00D1FF,
                                    ).withOpacity(0.25),
                                    blurRadius: 30,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.logout_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 24),

                            /// TITLE
                            const Text(
                              "See You Soon 👋",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// SUBTITLE
                            const Text(
                              "Are you sure you want to log out?\nYour study data has been safely synced.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 32),

                            /// LOGOUT BUTTON
                            CustomButton.loginButton(
                              text: 'Log out',
                              onPressed: () async {
                                // --- NEW: Start Loading ---
                                setState(() {
                                  isLoading = true;
                                });

                                final AuthService logout = await AuthService();

                                await logout
                                    .logOut(); // Added await to ensure it finishes before moving on
                                context.read<Authprovider>().clearUser();

                                if (!mounted) return;

                                // --- NEW: Stop Loading (Optional since we navigate, but good practice) ---
                                setState(() {
                                  isLoading = false;
                                });

                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            /// CANCEL BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Profilescreen(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFF8FAFC),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// SYNC STATUS
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.cloud_done_rounded,
                              color: Color(0xFF0052FF),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "All changes synced",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// --- NEW: THE LOADING OVERLAY ---
            if (isLoading)
              Container(
                color: Colors.white.withOpacity(
                  0.6,
                ), // Matches the clean white theme
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0052FF), // Primary blue color
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
