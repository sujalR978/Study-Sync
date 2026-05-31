import 'package:flutter/material.dart';
import 'package:study_sync/models/user_model.dart';
import 'package:study_sync/services/auth_service.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: AuthService().getCurrentUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (!snapshot.hasData) {
              return const Text('No data found');
            }
            UserModel? user = snapshot.data!;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(user.fullname),
                  Text(user.username),
                  Text(user.email),
                  Text(user.phone),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
