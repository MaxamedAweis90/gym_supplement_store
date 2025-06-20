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
      body: SafeArea(
        child: Column(
          children: [
            // Toggle buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => setState(() => showLogin = true),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontWeight: showLogin
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: showLogin ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => showLogin = false),
                  child: Text(
                    "Register",
                    style: TextStyle(
                      fontWeight: !showLogin
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: !showLogin ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(child: showLogin ? LoginPage() : RegisterPage()),
          ],
        ),
      ),
    );
  }
}
