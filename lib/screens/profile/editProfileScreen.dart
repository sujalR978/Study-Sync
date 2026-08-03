import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:study_sync/models/user_model.dart';
import 'package:study_sync/providers/auth_provider.dart';
import 'package:study_sync/screens/BottomNavigation.dart';
import 'package:study_sync/screens/profile/profileScreen.dart';
import 'package:study_sync/services/auth_service.dart';
import 'package:study_sync/services/update_auth_data.dart';
import 'package:study_sync/utils/profile_image_utils.dart';
import 'package:study_sync/widgets/profile_avatar.dart';

class Editprofilescreen extends StatefulWidget {
  const Editprofilescreen({super.key});

  @override
  State<Editprofilescreen> createState() => _EditprofilescreenState();
}

class _EditprofilescreenState extends State<Editprofilescreen> {
  final GlobalKey<FormState> keyForm = GlobalKey<FormState>();
  late TextEditingController fullname;
  late TextEditingController username;
  late TextEditingController phone;
  String Imagepath = '';
  bool isLoaded = false;
  String? photoUrl;

  bool _isSavePressed = false;
  bool _isCancelPressed = false;

  @override
  void dispose() {
    fullname.dispose();
    phone.dispose();
    username.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fullname = TextEditingController();
    username = TextEditingController();
    phone = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isLoaded) {
      final user = context.read<Authprovider>().user;
      fullname.text = user?.fullname ?? '';
      username.text = user?.username ?? '';
      phone.text = user?.phone ?? '';
      photoUrl = user?.photoUrl ?? '';
      isLoaded = true;
    }
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        Imagepath = image.path;
      });
    }
  }

  // --- REUSABLE MODERN TEXT FIELD BUILDER ---
  Widget _buildModernTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final fillColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.grey.withOpacity(0.08);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 20, right: 12),
              child: Icon(icon, color: primaryColor.withOpacity(0.8), size: 22),
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color primaryColor = theme.colorScheme.primary;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color scaffoldColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Stack(
        children: [
          // 1. DYNAMIC HEADER COVER BACKGROUND
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withOpacity(isDark ? 0.4 : 0.8),
                    secondaryColor.withOpacity(isDark ? 0.2 : 0.6),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative mesh circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. MAIN SCROLLABLE CONTENT
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // CUSTOM APP BAR (Transparent)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const Profilescreen(),
                          ),
                        ),
                        child: Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 44), // To balance the back button
                    ],
                  ),
                ),

                // OVERLAPPING BODY CONTAINER
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 40),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: scaffoldColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          // 3. OVERLAPPING AVATAR
                          Positioned(
                            top: -65,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.elasticOut,
                              builder: (context, val, child) {
                                return Transform.scale(
                                  scale: val,
                                  child: child,
                                );
                              },
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: scaffoldColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: ProfileAvatar(
                                      photoUrl: photoUrl ?? '',
                                      localImagePath: Imagepath.isNotEmpty
                                          ? Imagepath
                                          : null,
                                      radius: 65, // slightly larger
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: pickImage,
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                        right: 4,
                                        bottom: 4,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: scaffoldColor,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryColor.withOpacity(
                                              0.4,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // FORM BODY
                          Padding(
                            padding: const EdgeInsets.fromLTRB(28, 90, 28, 20),
                            child: Form(
                              key: keyForm,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Section Header
                                  Center(
                                    child: Text(
                                      "Update your details",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.5),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Inputs
                                  _buildModernTextField(
                                    context: context,
                                    label: 'FULL NAME',
                                    hint: 'Enter your full name',
                                    icon: Icons.person_rounded,
                                    controller: fullname,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z ]'),
                                      ),
                                    ],
                                    validator: (value) =>
                                        (value == null || value.isEmpty)
                                        ? 'Full name is required'
                                        : null,
                                  ),
                                  const SizedBox(height: 24),

                                  _buildModernTextField(
                                    context: context,
                                    label: 'USERNAME',
                                    hint: 'Choose a unique username',
                                    icon: Icons.alternate_email_rounded,
                                    controller: username,
                                    validator: (value) =>
                                        (value == null || value.isEmpty)
                                        ? 'Username is required'
                                        : null,
                                  ),
                                  const SizedBox(height: 24),

                                  _buildModernTextField(
                                    context: context,
                                    label: 'PHONE NUMBER',
                                    hint: 'Enter a 10-digit number',
                                    icon: Icons.phone_iphone_rounded,
                                    controller: phone,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Phone number is required';
                                      if (value.length != 10)
                                        return 'Must be exactly 10 digits';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 48),

                                  // --- SAVE BUTTON ---
                                  GestureDetector(
                                    onTapDown: (_) =>
                                        setState(() => _isSavePressed = true),
                                    onTapUp: (_) =>
                                        setState(() => _isSavePressed = false),
                                    onTapCancel: () =>
                                        setState(() => _isSavePressed = false),
                                    onTap: () async {
                                      if (keyForm.currentState!.validate()) {
                                        final uid = FirebaseAuth
                                            .instance
                                            .currentUser!
                                            .uid;
                                        String finalImageUrl = photoUrl ?? '';

                                        if (Imagepath.isNotEmpty) {
                                          finalImageUrl =
                                              await ProfileImageUtils.persistLocalImage(
                                                Imagepath,
                                                uid,
                                              );
                                        }

                                        await UpdateAuthData().updateAuthData(
                                          fullname: fullname.text,
                                          username: username.text,
                                          phone: phone.text,
                                          photoUrl: finalImageUrl,
                                        );

                                        if (FirebaseAuth.instance.currentUser !=
                                            null) {
                                          UserModel? userData =
                                              await AuthService()
                                                  .getCurrentUserData();
                                          if (userData != null &&
                                              context.mounted) {
                                            context
                                                .read<Authprovider>()
                                                .setUser(userData);
                                          }
                                        }

                                        if (context.mounted) {
                                          // 1. Close the Edit Profile Screen
                                          Navigator.of(context).pop();

                                          // 2. Switch bottom nav to Settings tab (Index 4)
                                          Bottomnavigation.of(
                                            context,
                                          )?.changeTab(4);

                                          // 3. Show Success SnackBar
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                'Changes completed successfully! ✨',
                                              ),
                                              backgroundColor:
                                                  Colors.green.shade600,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: AnimatedScale(
                                      scale: _isSavePressed ? 0.95 : 1.0,
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              primaryColor,
                                              secondaryColor,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryColor.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'Save Changes',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // --- CANCEL BUTTON ---
                                  GestureDetector(
                                    onTapDown: (_) =>
                                        setState(() => _isCancelPressed = true),
                                    onTapUp: (_) => setState(
                                      () => _isCancelPressed = false,
                                    ),
                                    onTapCancel: () => setState(
                                      () => _isCancelPressed = false,
                                    ),
                                    onTap: () {
                                      // 1. Close the Edit Profile Screen
                                      Navigator.of(context).pop();

                                      // 2. Switch bottom nav to Settings tab (Index 4)
                                      Bottomnavigation.of(
                                        context,
                                      )?.changeTab(4);

                                      // 3. Show Cancelled SnackBar
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Edit Cancelled.',
                                          ),
                                          backgroundColor: Colors.redAccent,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: AnimatedScale(
                                      scale: _isCancelPressed ? 0.95 : 1.0,
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white.withOpacity(0.05)
                                              : Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
