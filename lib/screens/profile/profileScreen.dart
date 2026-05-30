import 'package:flutter/material.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  String fullname = 'fgnfd';
  String username = ' fd';
  String email = 'dfsd@gamil.com';
  String phone = '1234567890';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(fullname),
              Text(username),
              Text(email),
              Text(phone),
            ],
          ),
        ),
      ),
    );
  }
}
