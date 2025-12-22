import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:medinest/presentation/diet/diet_dashboard_screen.dart';
import 'package:medinest/presentation/diet/diet_input_screen.dart';
import 'package:medinest/state/auth_provider.dart';
import 'package:medinest/state/diet_provider.dart';
import 'package:provider/provider.dart';

class DietRouter extends StatefulWidget {
  const DietRouter({super.key});

  @override
  State<DietRouter> createState() => _DietRouterState();
}

class _DietRouterState extends State<DietRouter> {
  @override
  void initState() {
    super.initState();
    _handleRouting();
  }

  Future<void> _handleRouting() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dietProvider = Provider.of<DietProvider>(context, listen: false);

    final uid = authProvider.userId ?? "test_user_123";

    // Always fetch the latest profile to decide where to go
    await dietProvider.fetchDietProfile(uid);

    if (!mounted) return;

    if (dietProvider.dietData != null &&
        dietProvider.dietData!['analysis'] != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DietDashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DietInputScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              child: Lottie.asset(
                'assets/lottie/upload.json',
                repeat: true,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Syncing Health Profile...",
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Preparing your personalized nutrition experience",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                  color: AppTheme.primaryGreen,
                  minHeight: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
