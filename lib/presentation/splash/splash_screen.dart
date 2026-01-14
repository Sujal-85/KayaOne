import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kayaone/core/localization/app_localizations.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/presentation/home/home_screen.dart';
import 'package:kayaone/presentation/intro/video_intro_screen.dart';
import 'package:kayaone/presentation/language/language_screen.dart';
import 'package:kayaone/presentation/auth/personal_info_screen.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/state/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late String _backgroundImage;

  final List<String> _splashImages = [
    'assets/images/splash_images/image.png',
    'assets/images/splash_images/image1.png',
    'assets/images/splash_images/image2.png',
    'assets/images/splash_images/image3.png',
  ];

  @override
  void initState() {
    super.initState();
    // Select a random image
    _backgroundImage = _splashImages[Random().nextInt(_splashImages.length)];
    // Precache logic could go here, but sticking to simple first

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      // Extended for debug visibility
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isLoggedIn = authProvider.isLoggedIn;
        final isOnboardingComplete = authProvider.isOnboardingComplete;

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              if (isLoggedIn) {
                return authProvider.isProfileComplete
                    ? const HomeScreen()
                    : const PersonalInfoScreen();
              } else {
                return isOnboardingComplete
                    ? const LanguageScreen()
                    : const VideoIntroScreen();
              }
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.milkyWhite,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Official App Logo with Glow
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 50,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16.0),
                          child: Image.asset(
                            'assets/images/logo_removebg.png', // Preferred transparent logo
                            height: 140,
                            width: 140,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              'assets/images/logo.png',
                              height: 140,
                              width: 140,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      loc?.translate('app_name') ?? 'KayaOne',
                        style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.1,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3), width: 1),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        loc?.translate('tagline') ??
                            'Healthcare at your doorstep',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Loading Indicator at Bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.8)),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
