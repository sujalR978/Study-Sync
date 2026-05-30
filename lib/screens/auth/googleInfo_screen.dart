import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_sync/screens/home/home_screen.dart';
import 'package:study_sync/services/auth_service.dart';

class googleInfoscreen extends StatefulWidget {
  const googleInfoscreen({super.key});

  @override
  State<googleInfoscreen> createState() => _googleInfoscreenState();
}

class _googleInfoscreenState extends State<googleInfoscreen> {
  final GlobalKey<FormState> keyForm = GlobalKey<FormState>();
  final TextEditingController username = TextEditingController();
  final TextEditingController phone = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    username.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Form(
                key: keyForm,
                child: Column(
                  children: [
                    TextFormField(
                      controller: username,
                      decoration: InputDecoration(hintText: 'Username'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter username.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      controller: phone,
                      decoration: InputDecoration(hintText: 'phone'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter username.';
                        }
                        if (value.length == 10) {
                          return 'Enter 10 digit';
                        }
                        return null;
                      },
                    ),

                    ElevatedButton(
                      onPressed: () {
                        if (keyForm.currentState!.validate()) {
                          AuthService auth = AuthService();
                          auth.googleUser(username: username, phone: phone);

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        }
                      },
                      child: Text('Next'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
