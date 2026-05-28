import 'package:flutter/material.dart';
import 'package:study_sync/widgets/custom_button.dart';
import 'package:study_sync/widgets/custom_textfield.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          /// BACKGROUND CIRCLES
          Positioned(
            top: 120,
            left: -80,

            child: Container(
              height: 250,
              width: 250,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: const Color(0xFF7DD3FC).withOpacity(0.15),
              ),
            ),
          ),

          Positioned(
            bottom: 120,
            right: -80,

            child: Container(
              height: 220,
              width: 220,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: const Color(0xFF6B4A9E).withOpacity(0.08),
              ),
            ),
          ),

          /// MAIN CONTENT
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  /// CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),

                      borderRadius: BorderRadius.circular(30),

                      border: Border.all(
                        color: const Color(0xFF0E4D6E).withOpacity(0.08),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),

                          blurRadius: 30,

                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        /// ICON
                        Container(
                          height: 90,
                          width: 90,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            color: const Color(0xFF7DD3FC).withOpacity(0.15),

                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF7DD3FC,
                                ).withOpacity(0.25),

                                blurRadius: 25,
                                spreadRadius: 3,
                              ),
                            ],
                          ),

                          child: const Icon(
                            Icons.account_circle,
                            size: 50,
                            color: Color(0xFF0E4D6E),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// TITLE
                        customText.titalText('Log out?'),

                        const SizedBox(height: 12),

                        /// SUBTITLE
                        const Text(
                          "Are you sure you want to log out?\nYour current study session progress is saved.",

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Color(0xFF4A6070),

                            fontSize: 15,

                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 35),

                        /// LOGOUT BUTTON
                        ///
                        CustomButton.loginButton(
                          text: 'Log out',
                          onPressed: () {},
                        ),

                        const SizedBox(height: 14),

                        /// CANCEL BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 54,

                          child: TextButton(
                            onPressed: () {},

                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),

                            child: const Text(
                              "Cancel",

                              style: TextStyle(
                                color: Color(0xFF4A6070),

                                fontWeight: FontWeight.w600,

                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// SYNC INFO
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(50),

                      border: Border.all(
                        color: const Color(0xFF0E4D6E).withOpacity(0.08),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),

                          blurRadius: 10,
                        ),
                      ],
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: const [
                        Icon(
                          Icons.cloud_done,
                          color: Color(0xFF0E4D6E),
                          size: 18,
                        ),

                        SizedBox(width: 8),

                        Text(
                          "Last session synced 2 mins ago",

                          style: TextStyle(
                            color: Color(0xFF4A6070),

                            fontSize: 13,

                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
