import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(25),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,

          children: [

            bottomNavItem(
              icon: Icons.home_rounded,
              isSelected: true,
            ),

            bottomNavItem(
              icon: Icons.calendar_month_rounded,
            ),

            bottomNavItem(
              icon: Icons.bar_chart_rounded,
            ),

            bottomNavItem(
              icon: Icons.person_outline_rounded,
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              /// TOP BAR
              Row(
                children: [

                  /// PROFILE
                  Container(
                    height: 55,
                    width: 55,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(0xFF0052FF),
                          Color(0xFF00D1FF),
                        ],
                      ),
                    ),

                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 14),

                  /// TEXT
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: const [

                      Text(
                        "Welcome Back 👋",

                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        "Sujal",

                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 22,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  /// NOTIFICATION
                  Container(
                    padding:
                        const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                              16),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.04),

                          blurRadius: 10,
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons.notifications_none,
                      color: Color(0xFF0F172A),
                    ),
    