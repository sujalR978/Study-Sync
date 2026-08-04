import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:study_sync/screens/Notes/EditNotes.dart';
import 'package:study_sync/screens/Notes/createNotes.dart';
import 'package:study_sync/screens/Notes/showNotes.dart';
import 'package:study_sync/services/Notes_service.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;
  bool _isNewNotePressed = false;

  // Tracking selected subject for filtering
  String _selectedSubject = 'All';

  @override
  void initState() {
    super.initState();
    // Continuous loop background tracking controller setup
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  // --- REFINED OPTIONS DIALOG ---
  void showOptionsDialog(
    String noteId,
    String noteTitle,
    bool isDark,
    Color primaryColor,
    Color surfaceColor,
    Color onSurfaceColor,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: AlertDialog(
              scrollable: true,
              insetPadding: const EdgeInsets.symmetric(horizontal: 60),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
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
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    noteTitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: onSurfaceColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Note Options",
                    style: TextStyle(
                      color: onSurfaceColor.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.black.withOpacity(0.03),
                      thickness: 1.2,
                    ),
                  ),
                  // --- EDIT ACTION ---
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Editnotes(noteId: noteId),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.edit_note_rounded,
                        color: primaryColor,
                        size: 20,
                      ),
                      label: Text(
                        'Edit Content',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // --- WARNING DELETE ACTION SYSTEM ---
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        showDeleteConfirmation(
                          noteId,
                          noteTitle,
                          isDark,
                          onSurfaceColor,
                          surfaceColor,
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFEF4444),
                        size: 18,
                      ),
                      label: const Text(
                        'Delete Note',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        overlayColor: const Color(0xFFEF4444).withOpacity(0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showDeleteConfirmation(
    String noteId,
    String noteTitle,
    bool isDark,
    Color onSurfaceColor,
    Color surfaceColor,
  ) {
    bool isDeleting = false;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: AlertDialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 40),
                  contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  backgroundColor: surfaceColor.withOpacity(
                    isDark ? 0.35 : 0.55,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.04),
                      width: 1.5,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isDeleting
                            ? Container(
                                padding: const EdgeInsets.all(16),
                                child: const SizedBox(
                                  height: 36,
                                  width: 36,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFEF4444),
                                    strokeWidth: 3.5,
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFEF4444,
                                  ).withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete_sweep_rounded,
                                  color: Color(0xFFEF4444),
                                  size: 32,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isDeleting ? 'Purging Note...' : 'Discard Note?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: onSurfaceColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            color: onSurfaceColor.withOpacity(0.55),
                            fontSize: 14,
                            height: 1.45,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  'Are you sure you want to permanently purge ',
                            ),
                            TextSpan(
                              text: '"$noteTitle"',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: onSurfaceColor,
                              ),
                            ),
                            const TextSpan(
                              text: '? This action cannot be reversed.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: TextButton(
                                onPressed: isDeleting
                                    ? null
                                    : () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: isDark
                                      ? Colors.white.withOpacity(0.04)
                                      : Colors.black.withOpacity(0.03),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: onSurfaceColor.withOpacity(0.8),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: isDeleting
                                    ? null
                                    : () async {
                                        setDialogState(() => isDeleting = true);
                                        await Future.delayed(
                                          const Duration(milliseconds: 600),
                                        );
                                        await NotesService().DeleteNotes(
                                          noteId,
                                        );
                                        if (context.mounted)
                                          Navigator.pop(context);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF4444),
                                  disabledBackgroundColor: const Color(
                                    0xFFEF4444,
                                  ).withOpacity(0.4),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  isDeleting ? 'Deleting' : 'Delete',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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

      // Removed the standard AppBar to use the Stack-based floating pill instead
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 95, right: 4),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isNewNotePressed = true),
          onTapUp: (_) => setState(() => _isNewNotePressed = false),
          onTapCancel: () => setState(() => _isNewNotePressed = false),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const Createnotes()),
            );
          },
          child: AnimatedScale(
            scale: _isNewNotePressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                ),
                borderRadius: BorderRadius.circular(27),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    "New Note",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          // ===================================================================
          // --- 1. CYCLIC LOOP BACKGROUND TASK ---
          // ===================================================================
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _NotesBackgroundPainter(
                    t: _bgController.value,
                    colors: [primaryColor, secondaryColor, primaryColor],
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),

          // ===================================================================
          // --- 2. MAIN SCROLLING CONTENT ---
          // ===================================================================
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: StreamBuilder<QuerySnapshot>(
                stream: NotesService().getNotes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_alt_rounded,
                            size: 80,
                            color: onSurfaceColor.withOpacity(0.1),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No Notes Found",
                            style: TextStyle(
                              color: onSurfaceColor.withOpacity(0.4),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final notes = snapshot.data!.docs;

                  // Extract unique subjects dynamically
                  Set<String> subjectSet = {'All'};
                  for (var doc in notes) {
                    final data = doc.data() as Map<String, dynamic>?;
                    String subj =
                        data != null &&
                            data.containsKey('subject') &&
                            data['subject'].toString().isNotEmpty
                        ? data['subject'].toString().trim()
                        : 'General';
                    subjectSet.add(subj);
                  }
                  List<String> subjectsList = subjectSet.toList();

                  // Filter the notes based on selection
                  List<QueryDocumentSnapshot> filteredNotes = notes;
                  if (_selectedSubject != 'All') {
                    filteredNotes = notes.where((doc) {
                      final data = doc.data() as Map<String, dynamic>?;
                      String subj =
                          data != null &&
                              data.containsKey('subject') &&
                              data['subject'].toString().isNotEmpty
                          ? data['subject'].toString().trim()
                          : 'General';
                      return subj == _selectedSubject;
                    }).toList();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 85,
                      ), // Added padding to clear the Floating App Bar
                      // --- SUBJECT FILTER CHIP LIST ROW ---
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: subjectsList.length,
                          itemBuilder: (context, index) {
                            String subject = subjectsList[index];
                            bool isSelected = _selectedSubject == subject;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSubject = subject;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.only(
                                  right: 10,
                                  top: 4,
                                  bottom: 8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            primaryColor,
                                            secondaryColor,
                                          ],
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
                                            color: primaryColor.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  subject,
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
                              ),
                            );
                          },
                        ),
                      ),

                      // --- NOTES GRID RENDER ---
                      Expanded(
                        child: filteredNotes.isEmpty
                            ? Center(
                                child: Text(
                                  "No notes in '$_selectedSubject'",
                                  style: TextStyle(
                                    color: onSurfaceColor.withOpacity(0.4),
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  10,
                                  16,
                                  150,
                                ),
                                itemCount: filteredNotes.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 14,
                                      crossAxisSpacing: 14,
                                      childAspectRatio: 0.85,
                                    ),
                                itemBuilder: (context, index) {
                                  final Map<String, dynamic>? data =
                                      filteredNotes[index].data()
                                          as Map<String, dynamic>?;
                                  String noteId = filteredNotes[index].id;
                                  String title =
                                      data?['title']?.toString() ?? 'Untitled';
                                  String body = data?['body']?.toString() ?? '';
                                  String subjectTag =
                                      data != null &&
                                          data.containsKey('subject') &&
                                          data['subject'].toString().isNotEmpty
                                      ? data['subject'].toString().trim()
                                      : 'General';

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              Shownotes(noteId: noteId),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 10,
                                          sigmaY: 10,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: surfaceColor.withOpacity(
                                              isDark ? 0.25 : 0.45,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                            border: Border.all(
                                              color: isDark
                                                  ? Colors.white.withOpacity(
                                                      0.06,
                                                    )
                                                  : Colors.black.withOpacity(
                                                      0.03,
                                                    ),
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: isDark
                                                    ? Colors.black26
                                                    : Colors.black.withOpacity(
                                                        0.02,
                                                      ),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(14.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: primaryColor
                                                            .withOpacity(0.15),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        subjectTag,
                                                        style: TextStyle(
                                                          color: primaryColor,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () =>
                                                          showOptionsDialog(
                                                            noteId,
                                                            title,
                                                            isDark,
                                                            primaryColor,
                                                            surfaceColor,
                                                            onSurfaceColor,
                                                          ),
                                                      child: Icon(
                                                        Icons.more_vert_rounded,
                                                        size: 20,
                                                        color: onSurfaceColor
                                                            .withOpacity(0.5),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  title,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 16,
                                                    height: 1.2,
                                                    color: onSurfaceColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Expanded(
                                                  child: Text(
                                                    body,
                                                    maxLines: 4,
                                                    overflow: TextOverflow.fade,
                                                    style: TextStyle(
                                                      fontSize: 12.5,
                                                      height: 1.5,
                                                      color: onSurfaceColor
                                                          .withOpacity(0.55),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ===================================================================
          // --- 3. FLOATING PILL APP BAR (Based on ProfileScreen) ---
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
                          // Left Icon (Book icon to represent Notes)
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.book_rounded,
                              color: primaryColor,
                              size: 20,
                            ),
                          ),

                          // Centered Title
                          Text(
                            'Notes Directory',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: onSurfaceColor,
                              fontSize: 18,
                              letterSpacing: -0.5,
                            ),
                          ),

                          // Right Icon (Matches the Profile sparkle style)
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.8, end: 1.2),
                              duration: const Duration(seconds: 2),
                              curve: Curves.easeInOut,
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: primaryColor,
                                    size: 18,
                                  ),
                                );
                              },
                              onEnd: () {},
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

// =====================================================================
// LOOPING NOTE-THEMED VECTOR BACKGROUND PAINTER CORE (Remains Unchanged)
// =====================================================================
class _NotesBackgroundPainter extends CustomPainter {
  final double t;
  final List<Color> colors;
  final bool isDark;

  _NotesBackgroundPainter({
    required this.t,
    required this.colors,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final Paint basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors.map((c) => c.withOpacity(isDark ? 0.12 : 0.05)).toList(),
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    final double angle1 = t * 2 * pi;
    final double angle2 = t * 2 * pi + pi;

    final Offset c1 = Offset(
      size.width * 0.22 + sin(angle1) * size.width * 0.20,
      size.height * 0.26 + cos(angle1) * size.height * 0.10,
    );
    final Offset c2 = Offset(
      size.width * 0.76 + cos(angle2) * size.width * 0.16,
      size.height * 0.70 + sin(angle2) * size.height * 0.14,
    );

    canvas.drawCircle(
      c1,
      size.width * 0.35,
      Paint()
        ..color = colors[0].withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 65),
    );
    canvas.drawCircle(
      c2,
      size.width * 0.4,
      Paint()
        ..color = colors.last.withOpacity(0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70),
    );

    // Floating note vector items looping forever
    const icons = [
      Icons.description_rounded,
      Icons.edit_note_rounded,
      Icons.assignment_rounded,
      Icons.draw_rounded,
      Icons.import_contacts_rounded,
      Icons.sticky_note_2_rounded,
    ];

    for (int i = 0; i < icons.length; i++) {
      final double progress = (t + i / icons.length) % 1.0;
      final double dx = size.width * (0.12 + 0.75 * ((i * 59) % 100) / 100);
      final double dy = size.height * (1.15 - progress * 1.35);
      final double fade = sin(progress * pi).clamp(0.0, 1.0);

      final TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
      tp.text = TextSpan(
        text: String.fromCharCode(icons[i].codePoint),
        style: TextStyle(
          fontSize: 22,
          fontFamily: icons[i].fontFamily,
          package: icons[i].fontPackage,
          color: colors[i % colors.length].withOpacity(0.16 * fade),
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(covariant _NotesBackgroundPainter oldDelegate) => true;
}
