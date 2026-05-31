import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_sync/widgets/custom_textfield.dart';

class Editprofilescreen extends StatefulWidget {
  const Editprofilescreen({super.key});

  @override
  State<Editprofilescreen> createState() => _EditprofilescreenState();
}

class _EditprofilescreenState extends State<Editprofilescreen> {
  final GlobalKey<FormState> keyForm = GlobalKey<FormState>();
  final TextEditingController fullname = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController phone = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    fullname.dispose();
    phone.dispose();
    username.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: keyForm,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextfield.customTextField(
              valideter: (Value) {
                if (Value == null || Value.isEmpty) {
                  return 'Enter Name.';
                }
                return null;
              },
              hintText: 'Enter name',
              icon: Icons.person,
              controller: fullname,
              regex: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
            ),
            CustomTextfield.customTextField(
              valideter: (Value) {
                if (Value == null || Value.isEmpty) {
                  return 'Enter Username.';
                }
                return null;
              },
              hintText: 'Enter Username',
              icon: Icons.person,
              controller: username,
            ),
            CustomTextfield.customTextField(
              valideter: (Value) {
                if (Value == null || Value.isEmpty) {
                  return 'Enter Phone number.';
                }
                if (Value.length != 10) {
                  return 'Enter 10 digit.';
                }
                return null;
              },
              hintText: 'Enter Phone',
              icon: Icons.person,
              controller: phone,
              regex: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
            ),

            ElevatedButton(
              onPressed: () {
                if (keyForm.currentState!.validate()) {}
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
