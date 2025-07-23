import 'package:flutter/material.dart';

class AppSplashScreen extends StatefulWidget {
  final Duration duration;
  final VoidCallback onFinish;
  final Widget? splashContent;

  const AppSplashScreen({
    Key? key,
    required this.duration,
    required this.onFinish,
    this.splashContent,
  }) : super(key: key);

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) widget.onFinish();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.splashContent != null) {
      return Scaffold(body: Center(child: widget.splashContent));
    }
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/strongguy.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: Colors.grey),
          ),
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
                      'This app is created by @engaweis and @engKaafi',
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
