import 'package:flutter/material.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:medinest/state/health_karma_provider.dart';
import 'package:medinest/data/services/health_karma_service.dart';
import 'package:medinest/presentation/healthkarma/health_karma_screen.dart';
import 'package:medinest/data/services/notification_service.dart';

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

    try {
      final result = await service.analyzeHealthData(provider.userResponses);
      if (mounted) {
        // Notification
        NotificationService().showNotification(
          title: "HealthKarma Score Ready! 🩺",
          body:
              "Your personalized health analysis is complete. See your results now.",
        );

        provider.setResults(result);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HealthKarmaScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Analysis failed: $e")),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Body Scan Animation Placeholder (Using a pulsing icon for now)
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
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
                  'assets/lottie/robot_hello.json', // Placeholder
                  width: 150,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              "Analyzing your lifestyle...",
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.teal.shade900,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2.seconds),
            const SizedBox(height: 12),
            Text(
              "AI is processing ${_getDynamicFact()}",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDynamicFact() {
    final facts = [
      "your biometric patterns...",
      "dietary impacts...",
      "sleep efficiency data...",
      "preventive risk factors...",
      "personalized health trends...",
    ];
    return facts[DateTime.now().second % facts.length];
  }
}
