import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart'; // ✅ Add this
import 'package:provider/provider.dart';
import 'package:gym_supplement_store/auth/register.dart';
import 'package:gym_supplement_store/widgets/bottomnav.dart';
import 'package:gym_supplement_store/admin/admin_login.dart';
import 'package:gym_supplement_store/providers/user_provider.dart';
import 'package:gym_supplement_store/widgets/splash_screen.dart';
import 'package:gym_supplement_store/auth/forgot_password.dart';

class LoginPage extends StatefulWidget {
  final String? emailFromRegister;

  const LoginPage({super.key, this.emailFromRegister});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    if (widget.emailFromRegister != null) {
      _emailController.text = widget.emailFromRegister!;
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

      await FirebaseAuth.instance.signInWithCredential(credential);

      // Initialize user data after successful login
      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).initializeUserData();

      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).fetchUserDataOnce();

      setState(() => _isLoading = false);

      Fluttertoast.showToast(
        msg: "✅ Signed in with Google!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SplashScreen(
            duration: const Duration(seconds: 4),
            nextScreen: const Bottomnav(),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _handleEmailPasswordLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Initialize user data after successful login
      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).initializeUserData();

      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).fetchUserDataOnce();

      setState(() => _isLoading = false);

      Fluttertoast.showToast(
        msg: "✅ Login successful!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SplashScreen(
            duration: const Duration(seconds: 4),
            nextScreen: const Bottomnav(),
          ),
        ),
      );
    } on FirebaseAuthException {
      setState(() {
        _isLoading = false;
        _error = "Incorrect email or password. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminLoginPage(),
                  ),
                );
              },
              icon: Icon(
                Icons.admin_panel_settings,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              label: Text(
                'Admin',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/login.png',
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Login",
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please sign in to continue.",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ForgotPasswordPage(
                              initialEmail: _emailController.text,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot password?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
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
                        onPressed: _handleEmailPasswordLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Sign in",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(height: 16),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: ElevatedButton.icon(
                    //     onPressed: _handleGoogleSignIn,
                    //     icon: Image.asset(
                    //       'assets/images/google.png',
                    //       height: 24,
                    //     ),
                    //     label: Text(
                    //       'Sign in with Google',
                    //       style: theme.textTheme.titleMedium,
                    //     ),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: theme.colorScheme.surface,
                    //       foregroundColor: theme.colorScheme.onSurface,
                    //       side: BorderSide(
                    //         color: theme.colorScheme.outline.withOpacity(0.3),
                    //       ),
                    //       padding: const EdgeInsets.symmetric(vertical: 12),
                    //     ),
                    //   ),
                    // ),
                  ],
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Don't have an account? Sign Up",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
