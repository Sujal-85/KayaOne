import 'package:flutter/material.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/state/health_karma_provider.dart';
import 'package:kayaone/data/services/health_karma_service.dart';
import 'package:kayaone/presentation/healthkarma/health_karma_screen.dart';
import 'package:kayaone/data/services/notification_service.dart';
import 'package:kayaone/core/localization/app_localizations.dart';

class AIAnalysisScreen extends StatefulWidget {
  const AIAnalysisScreen({super.key});

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    final provider = Provider.of<HealthKarmaProvider>(context, listen: false);
    final service = HealthKarmaService();
    // Cache context localizations before async gap if needed, or check mounted
    // However, AppLocalizations.of(context) needs context.

    try {
      final result = await service.analyzeHealthData(provider.userResponses);
      if (mounted) {
        var appLocalizations = AppLocalizations.of(context);
        // Notification
        // Notification
        NotificationService().showNotification(
          title: appLocalizations?.translate('kb_score_ready_title') ??
              "HealthKarma Score Ready! 🩺",
          body: appLocalizations?.translate('kb_score_ready_body') ??
              "Your personalized health analysis is complete. See your results now.",
        );

        await provider.saveScore(result);
        provider.setResults(result);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HealthKarmaScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        var appLocalizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "${appLocalizations?.translate('analysis_failed') ?? 'Analysis failed'}: $e")),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: LayoutBuilder(builder: (context, constraints) {
        final isSmall =
            constraints.maxWidth < 400 || constraints.maxHeight < 700;
        final containerSize = isSmall ? 160.0 : 200.0;
        final lottieSize = isSmall ? 120.0 : 150.0;
        final titleSize = isSmall ? 20.0 : 24.0;
        final spacing = isSmall ? 24.0 : 40.0;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Body Scan Animation Placeholder (Using a pulsing icon for now)
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: containerSize,
                    height: containerSize,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                          duration: 2.seconds,
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.2, 1.2))
                      .fadeOut(),
                  Lottie.asset(
                    'assets/lottie/Face scanning.json', // Placeholder
                    width: lottieSize,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              SizedBox(height: spacing),
              Text(
                appLocalizations?.translate('analyzing_lifestyle') ??
                    "Analyzing your lifestyle...",
                style: GoogleFonts.outfit(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                  color: Colors.teal.shade900,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 2.seconds),
              const SizedBox(height: 12),
              Text(
                "${appLocalizations?.translate('ai_processing') ?? 'AI is processing'} ${_getDynamicFact(context)}",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _getDynamicFact(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    final facts = [
      appLocalizations?.translate('fact_biometric') ??
          "your biometric patterns...",
      appLocalizations?.translate('fact_dietary') ?? "dietary impacts...",
      appLocalizations?.translate('fact_sleep') ?? "sleep efficiency data...",
      appLocalizations?.translate('fact_risk') ?? "preventive risk factors...",
      appLocalizations?.translate('fact_trends') ??
          "personalized health trends...",
    ];
    return facts[DateTime.now().second % facts.length];
  }
}
