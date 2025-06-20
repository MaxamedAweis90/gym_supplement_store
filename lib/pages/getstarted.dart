import 'package:flutter/material.dart';
import 'package:gym_supplement_store/auth/login.dart';
import 'package:gym_supplement_store/auth/register.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400, // Optional: limit max width for large screens
          child: showLogin ? LoginPage() : RegisterPage(),
        ),
      ),
    );
  }
}
