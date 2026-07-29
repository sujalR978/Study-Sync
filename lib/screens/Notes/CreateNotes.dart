import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_sync/screens/BottomNavigation.dart';
import 'package:study_sync/screens/Notes/Notes.dart';
import 'package:study_sync/services/Notes_service.dart';

class Createnotes extends StatefulWidget {
  const Createnotes({super.key});

  @override
  State<Createnotes> createState() => _CreatenotesState();
}

class _CreatenotesState extends State<Createnotes>
    with SingleTickerProviderStateMixin {
  final TextEditingController notesName = TextEditingController();
  final TextEditingController notesBody = TextEditingController();
  final GlobalKey<FormState> KeyForm = GlobalKey<FormState>();

  late AnimationController _loopController;
  bool _isSavePressed = false;

  @override
  void initState() {
    super.initState();
    // Continuous loop background tracking controller setup
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    notesBody.dispose();
    notesName.dispose();
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color onSurfaceColor = theme.colorScheme.onSurface;
    final Color surfaceColor = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // --- UPGRADED ATTRACTIVE GRADIENT APP BAR ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.02),
                width: 1.0,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 70,
            centerTitle: true,
            title: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [primaryColor, secondaryColor],
              ).createShader(bounds),
              child: const Text(
                'New Note',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            leadingWidth: 72,
            leading: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const Bottomnavigation(),
                        ),
                      );
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(isDark ? 0.35 : 0.45),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.04),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: onSurfaceColor.withOpacity(0.8),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isSavePressed = true),
                    onTapUp: (_) => setState(() => _isSavePressed = false),
                    onTapCancel: () => setState(() => _isSavePressed = false),
                    onTap: () {
                      if (KeyForm.currentState!.validate()) {
                        NotesService().AddNotes(
                          title: notesName.text,
                          body: notesBody.text,
                        );

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const Notes(),
                          ),
                        );
                      }
                    },
                    child: AnimatedScale(
                      scale: _isSavePressed ? 0.94 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, secondaryColor],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
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
      body: Stack(
        children: [
          // --- CYCLIC LOOP BACKGROUND ENGINE DESIGN ---
          AnimatedBuilder(
            animation: _loopController,
            builder: (context, child) {
              return Positioned(
                top: 40 + (25 * sin(_loopController.value * 2 * pi)),
                left: -50 + (30 * cos(_loopController.value * 2 * pi)),
                child: Container(
                  height: 260,
                  width: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(isDark ? 0.08 : 0.04),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(isDark ? 0.08 : 0.04),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _loopController,
            builder: (context, child) {
              return Positioned(
                bottom: 80 - (30 * sin(_loopController.value * 2 * pi)),
                right: -60 + (25 * cos(_loopController.value * 2 * pi)),
                child: Container(
                  height: 280,
                  width: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(isDark ? 0.08 : 0.04),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(isDark ? 0.08 : 0.04),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Form(
              key: KeyForm,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(isDark ? 0.30 : 0.45),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.04),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black38
                                : Colors.black.withOpacity(0.02),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 1. --- IMMERSIVE NOTE TITLE INPUT ---
                          TextFormField(
                            controller: notesName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: onSurfaceColor,
                              letterSpacing: -0.5,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter title...',
                              hintStyle: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: onSurfaceColor.withOpacity(0.3),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 4,
                              ),
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Add Note title'
                                : null,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp('[0-9a-zA-Z ]'),
                              ),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.03),
                              thickness: 1.5,
                            ),
                          ),

                          // 2. --- EXPANDED NOTE BODY INPUT ---
                          Expanded(
                            child: TextFormField(
                              controller: notesBody,
                              maxLines: null,
                              expands: true,
                              keyboardType: TextInputType.multiline,
                              textAlignVertical: TextAlignVertical.top,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: onSurfaceColor.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Start typing your study notes here...',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  color: onSurfaceColor.withOpacity(0.35),
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                              ),
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                  ? 'Add Note body'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
