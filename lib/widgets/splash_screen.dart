import 'package:flutter/material.dart';

/// A reusable splash screen widget that shows for [duration], then navigates to [nextScreen].
/// Optionally accepts [splashContent] for custom splash UI.
class SplashScreen extends StatefulWidget {
  final Duration duration;
  final Widget nextScreen;
  final Widget? splashContent;

  const SplashScreen({
    Key? key,
    required this.duration,
    required this.nextScreen,
    this.splashContent,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => widget.nextScreen));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.splashContent != null) {
      return Scaffold(body: Center(child: widget.splashContent));
    }
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset('assets/images/strongguy.png', fit: BoxFit.cover),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.85),
                  theme.colorScheme.secondary.withOpacity(0.85),
                ],
              ),
            ),
          ),
          // Centered logo and app name
          Column(
            children: [
              const Spacer(flex: 3),
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                  color: Colors.white,
                ),
              ),
              // const SizedBox(height: 24),
              const Spacer(flex: 4),
              // Bottom loading and credits
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      'This app is created by Engaweis and Eng Kaafi',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Example usage:
/// 
/// ElevatedButton(
///   onPressed: () {
///     Navigator.of(context).push(
///       MaterialPageRoute(
///         builder: (_) => SplashScreen(
///           duration: Duration(seconds: 2),
///           nextScreen: LoginPage(),
///         ),
///       ),
///     );
///   },
///   child: Text('Show Splash then Login'),
/// ) 