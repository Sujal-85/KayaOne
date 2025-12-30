import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kayaone/core/localization/app_localizations.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/presentation/language/language_screen.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/state/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'onboarding_1_title',
      'desc': 'onboarding_1_desc',
      'lottie': 'assets/lottie/gps_navigation.json',
      'icon': 'local_shipping',
    },
    {
      'title': 'onboarding_2_title',
      'desc': 'onboarding_2_desc',
      'lottie': 'assets/lottie/upload.json',
      'icon': 'upload_file',
    },
    {
      'title': 'onboarding_3_title',
      'desc': 'onboarding_3_desc',
      'lottie': 'assets/lottie/booking_calendar.json',
      'icon': 'medical_services',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.milkyWhite,
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                        border: Border.all(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                            width: 1),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 36,
                          width: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _navigateToLanguage(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.darkBlue.withValues(alpha: 0.6),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.translate('skip') ?? 'Skip',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return OnboardingContent(
                  title: AppLocalizations.of(context)
                          ?.translate(_onboardingData[index]['title']!) ??
                      '',
                  description: AppLocalizations.of(context)
                          ?.translate(_onboardingData[index]['desc']!) ??
                      '',
                  lottiePath: _onboardingData[index]['lottie']!,
                  index: index,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    _onboardingData.length,
                    (index) => buildDot(index),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_currentPage == _onboardingData.length - 1) {
                      _navigateToLanguage();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.fastOutSlowIn,
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 64,
                    width:
                        _currentPage == _onboardingData.length - 1 ? 160 : 64,
                    decoration: BoxDecoration(
                      color: AppTheme.darkBlue,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.darkBlue.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_currentPage == _onboardingData.length - 1) ...[
                          Text(
                            AppLocalizations.of(context)
                                    ?.translate('get_started') ??
                                'Get Started',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLanguage() {
    Provider.of<AuthProvider>(context, listen: false).completeOnboarding();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LanguageScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: _currentPage == index ? 32 : 8,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppTheme.primaryGreen
            : AppTheme.darkBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String title;
  final String description;
  final String lottiePath;
  final int index;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.description,
    required this.lottiePath,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isSmall = constraints.maxWidth < 400 || constraints.maxHeight < 700;
      final lottieHeightFactor = isSmall ? 0.25 : 0.35;
      final titleSize = isSmall ? 24.0 : 32.0;
      final descSize = isSmall ? 14.0 : 16.0;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(),
            SizedBox(
              height: MediaQuery.of(context).size.height * lottieHeightFactor,
              child: Lottie.asset(
                lottiePath,
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: descSize,
                color: AppTheme.darkBlue.withValues(alpha: 0.6),
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      );
    });
  }
}
