import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:study_sync/models/user_model.dart';
import 'package:study_sync/providers/auth_provider.dart';
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

  InputDecoration _lucidInputDecoration(
    BuildContext context,
    String hint,
    IconData icon,
    Color inputFill,
    Color textBodyColor,
    Color primaryColor,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: textBodyColor.withOpacity(0.4),
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      prefixIcon: Icon(
        icon,
        color: textBodyColor.withOpacity(0.7),
        size: 22,
      ),
      filled: true,
      fillColor: inputFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white.withOpacity(0.02) 
              : Colors.black.withOpacity(0.01),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 12),
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

    final Color dynamicTextBody = onSurfaceColor.withOpacity(0.55);
    final Color dynamicInputFill = Color.alphaBlend(
      primaryColor.withOpacity(isDark ? 0.12 : 0.06),
      surfaceColor,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // --- UPGRADED ATTRACTIVE GRADIENT APP BAR ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
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
                'Edit Profile',
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
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const Profilescreen()),
                    ),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: surfaceColor.withOpacity(isDark ? 0.35 : 0.45),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: onSurfaceColor.withOpacity(0.8),
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Ambient Background Emitters
          Positioned(
            top: -20,
            left: -50,
            child: Container(
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.07),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.12),
                    blurRadius: 55,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                builder: (context, val, child) {
                  return Opacity(
                    opacity: val,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1.0 - val)),
                      child: child,
                    ),
                  );
                },
                child: Form(
                  key: keyForm,
                  child: Column(
                    children: [
                      // --- UPGRADED INTERACTIVE AVATAR FRAME ---
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ProfileAvatar(
                            photoUrl: photoUrl ?? '',
                            localImagePath: Imagepath.isNotEmpty ? Imagepath : null,
                            radius: 60,
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 3.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),

                      // --- FORM CARD ACCENTED WITH GLASSMORPHIC BLUR ---
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: surfaceColor.withOpacity(isDark ? 0.30 : 0.45),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "PERSONAL INFORMATION",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: fullname,
                                  style: TextStyle(
                                    color: onSurfaceColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                                  ],
                                  validator: (value) => (value == null || value.isEmpty) ? 'Enter Name.' : null,
                                  decoration: _lucidInputDecoration(
                                    context, 'Full Name', Icons.person_rounded,
                                    dynamicInputFill, dynamicTextBody, primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: username,
                                  style: TextStyle(
                                    color: onSurfaceColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  validator: (value) => (value == null || value.isEmpty) ? 'Enter Username.' : null,
                                  decoration: _lucidInputDecoration(
                                    context, 'Username', Icons.alternate_email_rounded,
                                    dynamicInputFill, dynamicTextBody, primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  controller: phone,
                                  style: TextStyle(
                                    color: onSurfaceColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Enter Phone number.';
                                    if (value.length != 10) return 'Enter exactly 10 digits.';
                                    return null;
                                  },
                                  decoration: _lucidInputDecoration(
                                    context, 'Phone Number', Icons.phone_iphone_rounded,
                                    dynamicInputFill, dynamicTextBody, primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // --- THEME-REACTIVE ANIMATED SAVE CHANGES BUTTON ---
                      GestureDetector(
                        onTapDown: (_) => setState(() => _isSavePressed = true),
                        onTapUp: (_) => setState(() => _isSavePressed = false),
                        onTapCancel: () => setState(() => _isSavePressed = false),
                        onTap: () async {
                          if (keyForm.currentState!.validate()) {
                            final uid = FirebaseAuth.instance.currentUser!.uid;
                            String finalImageUrl = photoUrl ?? '';

                            if (Imagepath.isNotEmpty) {
                              finalImageUrl = await ProfileImageUtils.persistLocalImage(Imagepath, uid);
                            }

                            await UpdateAuthData().updateAuthData(
                              fullname: fullname.text,
                              username: username.text,
                              phone: phone.text,
                              photoUrl: finalImageUrl,
                            );

                            if (FirebaseAuth.instance.currentUser != null) {
                              UserModel? userData = await AuthService().getCurrentUserData();
                              if (userData != null && context.mounted) {
                                context.read<Authprovider>().setUser(userData);
                              }
                            }

                            if (context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const Profilescreen()),
                              );
                            }
                          }
                        },
                        child: AnimatedScale(
                          scale: _isSavePressed ? 0.96 : 1.0,
                          duration: const Duration(milliseconds: 120),
                          curve: Curves.easeOutCubic,
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [primaryColor, secondaryColor],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- THEME-REACTIVE ANIMATED CANCEL BUTTON ---
                      GestureDetector(
                        onTapDown: (_) => setState(() => _isCancelPressed = true),
                        onTapUp: (_) => setState(() => _isCancelPressed = false),
                        onTapCancel: () => setState(() => _isCancelPressed = false),
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const Profilescreen()),
                          );
                        },
                        child: AnimatedScale(
                          scale: _isCancelPressed ? 0.96 : 1.0,
                          duration: const Duration(milliseconds: 120),
                          curve: Curves.easeOutCubic,
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: surfaceColor.withOpacity(isDark ? 0.2 : 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: onSurfaceColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
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
        ],
      ),
    );
  }
}