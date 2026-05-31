import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_sync/models/user_model.dart';
import 'package:study_sync/providers/auth_provider.dart';
import 'package:study_sync/screens/profile/editProfileScreen.dart';
import 'package:study_sync/services/auth_service.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<Authprovider>().user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user.fullname),
            Text(user.username),
            Text(user.email),
            Text(user.phone),

            if (user.loginMethod == 'registor')
              Image.asset(user.photoUrl)
            else
              Image.network(user.photoUrl),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Editprofilescreen()),
                );
              },
              child: Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}
