import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart'; // ✅ Import
import 'package:gym_supplement_store/auth/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _error;

  void _showError(String message) {
    setState(() {
      _error = message;
      _isLoading = false;
    });
  }

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty) {
      _showError("Username cannot be empty.");
      return;
    }
    if (email.isEmpty) {
      _showError("Email cannot be empty.");
      return;
    }
    if (password.isEmpty) {
      _showError("Password cannot be empty.");
      return;
    }
    if (password.length < 6) {
      _showError("Password must be at least 6 characters.");
      return;
    }
    if (password != confirmPassword) {
      _showError("Passwords do not match.");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'username': username,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          });

      setState(() => _isLoading = false);
      print("✅ Registration successful");

      // ✅ Show Toast
      Fluttertoast.showToast(
        msg: "✅ Registration successful! Please login.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // ✅ Go to Login Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage(emailFromRegister: email)),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Registration failed.");
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'username': googleUser.displayName ?? '',
              'email': googleUser.email,
              'createdAt': FieldValue.serverTimestamp(),
            });
      }

      setState(() => _isLoading = false);
      print("✅ Google sign-in successful");

      // ✅ Toast
      Fluttertoast.showToast(
        msg: "✅ Signed in with Google!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // ✅ Go to Login Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double formWidth = screenWidth < 500 ? screenWidth * 0.95 : 400;

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              width: formWidth,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/register.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Register",
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Please register to continue.",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _usernameController,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      hintText: "Username",
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      hintText: "Email",
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      hintText: "Password",
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      suffixIcon: Icon(
                        Icons.visibility_off_outlined,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      hintText: "Confirm Password",
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      suffixIcon: Icon(
                        Icons.visibility_off_outlined,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (_) {},
                        activeColor: theme.colorScheme.primary,
                      ),
                      Text(
                        "Remind me next time",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    )
                  else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Sign Up",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handleGoogleSignIn,
                        icon: Image.asset(
                          'assets/images/google.png',
                          height: 24,
                        ),
                        label: Text(
                          'Sign Up with Google',
                          style: theme.textTheme.titleMedium,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface,
                          foregroundColor: theme.colorScheme.onSurface,
                          side: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Already have an account? Sign in",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
