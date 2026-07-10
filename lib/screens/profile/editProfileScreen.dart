import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:study_sync/models/user_model.dart';

import 'package:study_sync/providers/auth_provider.dart';
import 'package:study_sync/screens/BottomNavigation.dart';
import 'package:study_sync/screens/profile/profileScreen.dart';
import 'package:study_sync/services/auth_service.dart';
import 'package:study_sync/services/update_auth_data.dart';
import 'package:study_sync/constants/app_colors.dart';
import 'package:study_sync/utils/profile_image_utils.dart';
import 'package:study_sync/widgets/profile_avatar.dart';

class Editprofilescreen extends StatefulWidget  {
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
    final user = context.read<Authprovider>().user;

    fullname.text = user?.fullname ?? '';
    username.text = user?.username ?? '';
    phone.text = user?.phone ?? '';
    photoUrl = user?.photoUrl ?? '';

    isLoaded = true;
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        Imagepath = image.path;
      });
    }

    print(Imagepath);
  }

  InputDecoration _lucidInputDecoration(
    BuildContext context,
    String hint,
    IconData icon,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? AppColors.darkTextBody : AppColors.textBody,
        fontSize: 15,
      ),
      prefixIcon: Icon(
        icon,
        color: isDark ? AppColors.darkTextBody : AppColors.textBody,
      ),
      filled: true,
      fillColor: isDark ? AppColors.darkInputFill : AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // FIXED: Adaptive background framework binding
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Profilescreen()),
          ),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: keyForm,
            child: Column(
              children: [
                // --- AVATAR UI ---
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ProfileAvatar(
                      photoUrl: photoUrl ?? '',
                      localImagePath: Imagepath.isNotEmpty ? Imagepath : null,
                      radius: 64,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).scaffoldBackgroundColor, 
                              width: 4,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // --- INPUT FIELDS CARD ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface, 
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black26
                            : Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Personal Information",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: fullname,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z ]'),
                          ),
                        ],
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Enter Name.'
                            : null,
                        decoration: _lucidInputDecoration(
                          context,
                          'Full Name',
                          Icons.person_outline,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: username,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Enter Username.'
                            : null,
                        decoration: _lucidInputDecoration(
                          context,
                          'Username',
                          Icons.alternate_email,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: phone,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Phone number.';
                          }
                          if (value.length != 10) {
                            return 'Enter exactly 10 digits.';
                          }
                          return null;
                        },
                        decoration: _lucidInputDecoration(
                          context,
                          'Phone Number',
                          Icons.phone_outlined,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // --- SAVE BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (keyForm.currentState!.validate()) {
                        final uid = FirebaseAuth.instance.currentUser!.uid;
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
                        if (FirebaseAuth.instance.currentUser != null) {
                          UserModel? userData = await AuthService()
                              .getCurrentUserData();

                          if (userData != null && context.mounted) {
                            context.read<Authprovider>().setUser(userData);
                          }
                        }
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const Profilescreen(),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // --- CANCEL BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const Bottomnavigation(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      // FIXED: Adaptive cancel button background
                      backgroundColor: isDark
                          ? AppColors.darkInputFill
                          : AppColors.inputFill,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
