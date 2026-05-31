import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:study_sync/models/user_model.dart';

import 'package:study_sync/providers/auth_provider.dart';
import 'package:study_sync/screens/profile/profileScreen.dart';
import 'package:study_sync/services/auth_service.dart';
import 'package:study_sync/services/update_auth_data.dart';
import 'package:study_sync/constants/app_colors.dart'; // Adjust path if needed

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

  InputDecoration _lucidInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textBody, fontSize: 15),
      prefixIcon: Icon(icon, color: AppColors.textBody),
      filled: true,
      fillColor: AppColors.inputFill,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Profilescreen()),
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.neutral,
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
                    CircleAvatar(
                      radius: 64,
                      backgroundColor: AppColors.inputFill,
                      // ONLY THIS IMAGE LOGIC WAS UPDATED
                      backgroundImage: Imagepath.isNotEmpty
                          ? FileImage(File(Imagepath))
                          : (photoUrl != null && photoUrl!.isNotEmpty)
                          ? (photoUrl!.startsWith('http')
                                ? NetworkImage(photoUrl!) as ImageProvider
                                : (photoUrl!.startsWith('/data/')
                                      ? FileImage(File(photoUrl!))
                                            as ImageProvider
                                      : AssetImage(photoUrl!)))
                          : null,
                      child:
                          (Imagepath.isEmpty &&
                              (photoUrl == null || photoUrl!.isEmpty))
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.textBody,
                            )
                          : null,
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
                              color: AppColors.background,
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
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Personal Information",
                        style: TextStyle(
                          color: AppColors.neutral,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: fullname,
                        style: const TextStyle(
                          color: AppColors.neutral,
                          fontWeight: FontWeight.w500,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z ]'),
                          ),
                        ],
                        validator: (Value) => (Value == null || Value.isEmpty)
                            ? 'Enter Name.'
                            : null,
                        decoration: _lucidInputDecoration(
                          'Full Name',
                          Icons.person_outline,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: username,
                        style: const TextStyle(
                          color: AppColors.neutral,
                          fontWeight: FontWeight.w500,
                        ),
                        validator: (Value) => (Value == null || Value.isEmpty)
                            ? 'Enter Username.'
                            : null,
                        decoration: _lucidInputDecoration(
                          'Username',
                          Icons.alternate_email,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: phone,
                        style: const TextStyle(
                          color: AppColors.neutral,
                          fontWeight: FontWeight.w500,
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (Value) {
                          if (Value == null || Value.isEmpty)
                            return 'Enter Phone number.';
                          if (Value.length != 10)
                            return 'Enter exactly 10 digits.';
                          return null;
                        },
                        decoration: _lucidInputDecoration(
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
                        UpdateAuthData().updateAuthData(
                          fullname: fullname.text,
                          username: username.text,
                          phone: phone.text,
                          photoUrl: Imagepath,
                        );
                        if (FirebaseAuth.instance.currentUser != null) {
                          UserModel? userData = await AuthService()
                              .getCurrentUserData();

                          if (userData != null) {
                            context.read<Authprovider>().setUser(userData);
                          }
                        }
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const Profilescreen(),
                          ),
                        );
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
                          builder: (context) => const Profilescreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.inputFill,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.neutral,
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
