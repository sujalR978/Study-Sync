import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

import 'package:study_sync/screens/Notes/shownotes.dart'; // Ensure correct import for your Shownotes screen

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> with TickerProviderStateMixin {
  late AnimationController _bgController;

  // Default subjects
  List<String> _subjects = ['All', 'Mathematics', 'Physics', 'Literature'];
  String _selectedSubject = 'All';

  @override
  void initState() {
    super.initState();
    // Ambient background breathing effect
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _fetchCustomSubjects();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  // Fetch any additional custom subjects the user has created
  void _fetchCustomSubjects() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists && doc.data()!.containsKey('customSubjects')) {
      List<String> fetched = List<String>.from(doc.data()!['customSubjects']);
      setState(() {
        for (String sub in fetched) {
          if (!_subjects.contains(sub)) _subjects.add(sub);
        }
      });
    }
  }

  // Add a new subject to Firestore and UI
  void _addNewSubject(String subject) async {
    if (subject.trim().isEmpty || _subjects.contains(subject.trim())) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'customSubjects': FieldValue.arrayUnion([subject.trim()]),
      }, SetOptions(merge: true));
    }

    setState(() {
      _subjects.add(subject.trim());
      _selectedSubject = subject.trim(); // Auto-select new subject
    });
  }

  // --- STUNNING GLASSMORPHIC DIALOG TO ADD SUBJECT ---
  void _showAddSubjectDialog(
    BuildContext context,
    Color primaryColor,
    Color surfaceColor,
  ) {
    TextEditingController subjectController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceColor.withOpacity(isDark ? 0.4 : 0.7),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.library_books_rounded,
                        color: primaryColor,
                        size: 40,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "New Subject",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: subjectController,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: "e.g., Biology, Economics...",
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.4),
                          ),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.05),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onPressed: () {
                                _addNewSubject(subjectController.text);
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Create",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final scaffoldColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.colorScheme.surface;

    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Firestore Query based on selected subject
    Query notesQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notes')
        .orderBy('createdAt', descending: true);
    if (_selectedSubject != 'All') {
      notesQuery = notesQuery.where('subject', isEqualTo: _selectedSubject);
    }

    return Scaffold(
      backgroundColor: scaffoldColor,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ===================================================================
          // --- 1. DYNAMIC HYPNOTIC MESH BACKGROUND ---
          // ===================================================================
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              final double t = _bgController.value;
              final size = MediaQuery.of(context).size;
              return Stack(
                children: [
                  _buildOrganicBlob(
                    color: primaryColor.withOpacity(isDark ? 0.35 : 0.25),
                    t: t,
                    baseX: size.width * 0.8,
                    baseY: size.height * 0.2,
                    radius: 200,
                    driftSpeed: 1.2,
                    offsetSeed: 0,
                  ),
                  _buildOrganicBlob(
                    color: secondaryColor.withOpacity(isDark ? 0.25 : 0.15),
                    t: t,
                    baseX: size.width * 0.1,
                    baseY: size.height * 0.6,
                    radius: 250,
                    driftSpeed: 1.0,
                    offsetSeed: math.pi / 2,
                  ),
                ],
              );
            },
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(color: Colors.transparent),
            ),
          ),

          // ===================================================================
          // --- 2. MAIN CONTENT ---
          // ===================================================================
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "My Notes",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: onSurfaceColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: primaryColor,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- HORIZONTAL SUBJECT SELECTOR ---
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _subjects.length + 1, // +1 for the Add Button
                    itemBuilder: (context, index) {
                      // ADD SUBJECT BUTTON (Always at the end)
                      if (index == _subjects.length) {
                        return GestureDetector(
                          onTap: () => _showAddSubjectDialog(
                            context,
                            primaryColor,
                            surfaceColor,
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(left: 8, right: 20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: onSurfaceColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: onSurfaceColor.withOpacity(0.1),
                                width: 1.5,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  color: onSurfaceColor.withOpacity(0.6),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Add",
                                  style: TextStyle(
                                    color: onSurfaceColor.withOpacity(0.6),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // SUBJECT CHIPS
                      final subject = _subjects[index];
                      final isSelected = _selectedSubject == subject;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedSubject = subject),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor
                                : surfaceColor.withOpacity(isDark ? 0.3 : 0.6),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : onSurfaceColor.withOpacity(0.05),
                              width: 1.5,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              subject,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : onSurfaceColor.withOpacity(0.7),
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // --- NOTES GRID/LIST ---
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: notesQuery.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_rounded,
                                size: 60,
                                color: onSurfaceColor.withOpacity(0.2),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No notes in $_selectedSubject",
                                style: TextStyle(
                                  color: onSurfaceColor.withOpacity(0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var note = snapshot.data!.docs[index];
                          Map<String, dynamic> data =
                              note.data() as Map<String, dynamic>;

                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Shownotes(noteId: note.id),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: surfaceColor.withOpacity(
                                      isDark ? 0.3 : 0.6,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: onSurfaceColor.withOpacity(0.05),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Note Subject Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: secondaryColor.withOpacity(
                                            0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          data['subject'] ?? 'Uncategorized',
                                          style: TextStyle(
                                            color: secondaryColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Note Title
                                      Text(
                                        data['title'] ?? 'Untitled',
                                        style: TextStyle(
                                          color: onSurfaceColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      // Note Body
                                      Expanded(
                                        child: Text(
                                          data['body'] ?? '',
                                          style: TextStyle(
                                            color: onSurfaceColor.withOpacity(
                                              0.6,
                                            ),
                                            fontSize: 13,
                                            height: 1.4,
                                          ),
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
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
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // --- FLOATING ADD NOTE BUTTON ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to your Create Note screen.
          // Make sure to pass the _subjects list so the user can pick a subject for the new note!
        },
        backgroundColor: primaryColor,
        elevation: 10,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "New Note",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- BACKGROUND ANIMATION HELPER ---
  Widget _buildOrganicBlob({
    required Color color,
    required double t,
    required double baseX,
    required double baseY,
    required double radius,
    required double driftSpeed,
    required double offsetSeed,
  }) {
    final breathingVal = math.sin(t * math.pi * 2 + offsetSeed);
    final xOffset = breathingVal * 35 * driftSpeed;
    final yOffset = math.cos(t * math.pi * 1.5 + offsetSeed) * 25 * driftSpeed;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
      top: baseY + yOffset,
      left: baseX + xOffset,
      child: Container(
        height: radius * 2,
        width: radius * 2,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
