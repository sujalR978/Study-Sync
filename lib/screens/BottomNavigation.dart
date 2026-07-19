import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:study_sync/screens/home/home_screen.dart';
import 'package:study_sync/screens/Notes/Notes.dart';
import 'package:study_sync/screens/profile/profileScreen.dart';
import 'package:study_sync/screens/setting/setting_screen.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  int _currentIndex = 0;

  // REMOVED: Global Navigator keys are no longer needed since
  // sub-pages will now pop over the top of the entire shell layout structure.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color primaryColor = theme.colorScheme.primary;
    final Color surfaceColor = theme.colorScheme.surface;
    final Color onSurfaceColor = theme.colorScheme.onSurface;

    return Scaffold(
      extendBody:
          true, // Forces child layout canvases to sit behind the translucent glass container docks
      backgroundColor: theme.scaffoldBackgroundColor,

      body: Stack(
        children: [
          // Ambient Glass Distorter Orb
          Positioned(
            bottom: 40,
            left: 50,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.06),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.06),
                    blurRadius: 40,
                    spreadRadius: 20,
                    offset: Offset.zero,
                  ),
                ],
              ),
            ),
          ),

          // Core Tab Switch Transition Engine Layer
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.01),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: IndexedStack(
              key: ValueKey<int>(_currentIndex),
              index: _currentIndex,
              children: const [
                // UPGRADED: Removed local _buildNavigator scopes.
                // Tabs are now loaded directly as clear plain panels.
                HomeScreen(),
                Notes(),
                Notes(), // Secondary placeholder notes pointer slot matching your tracking system
                Profilescreen(),
                SettingScreen(),
              ],
            ),
          ),
        ],
      ),

      // Refactored Translucent Floating Glass Dock Layout
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: surfaceColor.withOpacity(isDark ? 0.35 : 0.45),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.black.withOpacity(0.06),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        0,
                        Icons.home_rounded,
                        "Home",
                        primaryColor,
                        onSurfaceColor,
                      ),
                      _buildNavItem(
                        1,
                        Icons.notes_rounded,
                        "Notes",
                        primaryColor,
                        onSurfaceColor,
                      ),
                      _buildNavItem(
                        2,
                        Icons.folder_copy_rounded,
                        "Files",
                        primaryColor,
                        onSurfaceColor,
                      ),
                      _buildNavItem(
                        3,
                        Icons.person_rounded,
                        "Profile",
                        primaryColor,
                        onSurfaceColor,
                      ),
                      _buildNavItem(
                        4,
                        Icons.settings_rounded,
                        "Setting",
                        primaryColor,
                        onSurfaceColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color primaryColor,
    Color onSurfaceColor,
  ) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? primaryColor
                  : onSurfaceColor.withOpacity(0.45),
              size: 22,
            ),
            AnimatedCrossFade(
              firstChild: Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Text(
                  label,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: isSelected
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 150),
            ),
          ],
        ),
      ),
    );
  }
}
