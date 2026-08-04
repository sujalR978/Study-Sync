import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController newTagController = TextEditingController();
  final GlobalKey<FormState> KeyForm = GlobalKey<FormState>();

  late AnimationController _loopController;

  // UX State variables
  bool _isSavePressed = false;
  bool _isSaving = false; // Prevents double-taps on the save button

  // --- NEW LOGIC: Tags System ---
  List<String> _availableTags = ['General', 'Math', 'Science', 'Ideas'];
  String _selectedTag = 'General';

  @override
  void initState() {
    super.initState();
    // Continuous loop background tracking controller setup
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    notesBody.dispose();
    notesName.dispose();
    newTagController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  // --- SUCCESS DIALOG UI ---
  void _showSuccessDialog(
    Color primaryColor,
    Color surfaceColor,
    Color onSurfaceColor,
    bool isDark,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force user to wait for auto-navigation
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: surfaceColor.withOpacity(isDark ? 0.45 : 0.65),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.04),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: primaryColor,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Note Created!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: onSurfaceColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your new note is safely stored.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: onSurfaceColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- ADD TAG DIALOG ---
  void _showAddTagDialog(
    Color primaryColor,
    Color surfaceColor,
    Color onSurfaceColor,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: AlertDialog(
              backgroundColor: surfaceColor.withOpacity(isDark ? 0.45 : 0.65),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.04),
                  width: 1.5,
                ),
              ),
              title: Text(
                "Create New Tag",
                style: TextStyle(
                  color: onSurfaceColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: TextField(
                controller: newTagController,
                style: TextStyle(color: onSurfaceColor),
                decoration: InputDecoration(
                  hintText: "E.g., History",
                  hintStyle: TextStyle(color: onSurfaceColor.withOpacity(0.4)),
                  filled: true,
                  fillColor: onSurfaceColor.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: onSurfaceColor.withOpacity(0.6)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (newTagController.text.trim().isNotEmpty) {
                      setState(() {
                        String newTag = newTagController.text.trim();
                        if (!_availableTags.contains(newTag)) {
                          _availableTags.insert(
                            1,
                            newTag,
                          ); // Insert right after 'General'
                        }
                        _selectedTag =
                            newTag; // Auto-select the newly created tag
                      });
                      newTagController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Create",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- DELETE TAG DIALOG ---
  void _showDeleteTagDialog(
    String tag,
    Color primaryColor,
    Color surfaceColor,
    Color onSurfaceColor,
    bool isDark,
  ) {
    if (tag == 'General') return; // Protect the default tag from being deleted

    showDialog(
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: AlertDialog(
              backgroundColor: surfaceColor.withOpacity(isDark ? 0.45 : 0.65),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.04),
                  width: 1.5,
                ),
              ),
              title: Text(
                "Delete Tag?",
                style: TextStyle(
                  color: onSurfaceColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                "Are you sure you want to remove the tag '$tag'?\nThis won't delete existing notes.",
                style: TextStyle(color: onSurfaceColor.withOpacity(0.8)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: onSurfaceColor.withOpacity(0.6)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _availableTags.remove(tag);
                      if (_selectedTag == tag) {
                        _selectedTag = 'General';
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: Stack(
        children: [
          // ===================================================================
          // --- 1. CYCLIC LOOP BACKGROUND ENGINE DESIGN ---
          // ===================================================================
          AnimatedBuilder(
            animation: _loopController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: 80 + (35 * sin(_loopController.value * 2 * pi)),
                    left: -40 + (30 * cos(_loopController.value * 2 * pi)),
                    child: _buildAmbientGlow(primaryColor, isDark),
                  ),
                  Positioned(
                    bottom: 80 - (35 * sin(_loopController.value * 2 * pi)),
                    right: -50 + (30 * cos(_loopController.value * 2 * pi)),
                    child: _buildAmbientGlow(secondaryColor, isDark),
                  ),
                ],
              );
            },
          ),

          // ===================================================================
          // --- 2. MAIN CONTENT (TAGS & FORM) ---
          // ===================================================================
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(
                  height: 85,
                ), // Spacer to clear the floating app bar
                // --- TAG SELECTOR ROW ---
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ..._availableTags.map((tag) {
                        bool isSelected = _selectedTag == tag;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTag = tag;
                            });
                          },
                          onLongPress: () => _showDeleteTagDialog(
                            tag,
                            primaryColor,
                            surfaceColor,
                            onSurfaceColor,
                            isDark,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(
                              right: 10,
                              top: 4,
                              bottom: 8,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [primaryColor, secondaryColor],
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : surfaceColor.withOpacity(
                                      isDark ? 0.3 : 0.6,
                                    ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : (isDark
                                          ? Colors.white12
                                          : Colors.black12),
                                width: 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                if (isSelected)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                Text(
                                  tag,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : onSurfaceColor.withOpacity(0.7),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      // Add Tag Button
                      GestureDetector(
                        onTap: () => _showAddTagDialog(
                          primaryColor,
                          surfaceColor,
                          onSurfaceColor,
                          isDark,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(top: 4, bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_rounded,
                                color: primaryColor,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Add",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- NOTE WRITING FORM ---
                Expanded(
                  child: Form(
                    key: KeyForm,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: surfaceColor.withOpacity(
                                isDark ? 0.30 : 0.45,
                              ),
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
                                      (value == null || value.trim().isEmpty)
                                      ? 'Add Note title'
                                      : null,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp('[0-9a-zA-Z ]'),
                                    ),
                                  ],
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                  ),
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
                                        (value == null || value.trim().isEmpty)
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
          ),

          // ===================================================================
          // --- 3. FLOATING PILL APP BAR ---
          // ===================================================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(isDark ? 0.35 : 0.65),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: onSurfaceColor.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left Icon (Close Button)
                          GestureDetector(
                            onTap: () {
                              // --- FIXED NAVIGATION ---
                              // Simply pops off the Create screen revealing BottomNavigation underneath
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: onSurfaceColor.withOpacity(
                                  isDark ? 0.08 : 0.05,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: onSurfaceColor.withOpacity(0.8),
                                size: 20,
                              ),
                            ),
                          ),

                          // Centered Title
                          Text(
                            'Draft Note',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: onSurfaceColor,
                              fontSize: 18,
                              letterSpacing: -0.5,
                            ),
                          ),

                          // Right Icon (Save Button Pill)
                          GestureDetector(
                            onTapDown: (_) =>
                                setState(() => _isSavePressed = true),
                            onTapUp: (_) =>
                                setState(() => _isSavePressed = false),
                            onTapCancel: () =>
                                setState(() => _isSavePressed = false),
                            onTap: () async {
                              // Safeguard to prevent double saving
                              if (KeyForm.currentState!.validate() &&
                                  !_isSaving) {
                                setState(() => _isSaving = true);

                                // 1. Save note to firestore
                                await NotesService().AddNotes(
                                  title: notesName.text,
                                  body: notesBody.text,
                                  subject: _selectedTag,
                                );

                                // 2. Show Success Animation
                                if (mounted) {
                                  _showSuccessDialog(
                                    primaryColor,
                                    surfaceColor,
                                    onSurfaceColor,
                                    isDark,
                                  );

                                  // 3. Wait for the user to see the checkmark
                                  await Future.delayed(
                                    const Duration(milliseconds: 1400),
                                  );

                                  // 4. Safely Navigate Back to Notes Tab
                                  if (mounted) {
                                    Navigator.pop(context); // Pops the Dialog
                                    Navigator.pop(
                                      context,
                                    ); // Pops the Createnotes screen!
                                  }
                                }
                              }
                            },
                            child: AnimatedScale(
                              scale: _isSavePressed ? 0.94 : 1.0,
                              duration: const Duration(milliseconds: 100),
                              child: Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryColor, secondaryColor],
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isSaving
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Save',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for background glows
  Widget _buildAmbientGlow(Color color, bool isDark) {
    return Container(
      height: 280,
      width: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(isDark ? 0.08 : 0.04),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.06 : 0.03),
            blurRadius: 70,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}
