import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:medinest/state/diet_provider.dart';
import 'package:medinest/state/auth_provider.dart';
import 'package:medinest/presentation/diet/diet_plan_detail_screen.dart';

class DietDashboardScreen extends StatefulWidget {
  const DietDashboardScreen({super.key});

  @override
  State<DietDashboardScreen> createState() => _DietDashboardScreenState();
}

class _DietDashboardScreenState extends State<DietDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final uid = auth.userId ?? "test_user_123";
      Provider.of<DietProvider>(context, listen: false).fetchDietProfile(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dietProvider = Provider.of<DietProvider>(context);
    final diet = dietProvider.dietData;

    if (dietProvider.isLoading && diet == null) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen)));
    }

    if (diet == null || diet['analysis'] == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.no_food_rounded,
                  size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text("No Diet Profile found",
                  style: GoogleFonts.outfit(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text("Please complete your health assessment",
                  style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final analysis = diet['analysis'] ?? {};
    final metrics = diet['metrics'] ?? {};
    final tracking = diet['tracking'] ?? {};
    final goalKcal = analysis['suggestedKcal'] ?? 2000;
    final eatenKcal = tracking['dailyCaloriesEaten'] ?? 0;
    final bmiStatus = analysis['bmiStatus'] ?? 'Processing...';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text("Vitals & Diet",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calorie Tracker Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.bolt_rounded,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$eatenKcal kcal Eaten",
                            style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white)),
                        Text("Today's Goal $goalKcal kcal",
                            style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAddCalorieDialog(context),
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Weight & BMI Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Weight - Findings",
                      style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.blue)),
                  const Divider(height: 32),
                  Text(bmiStatus,
                      style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricCol(
                          "Current Weight", "${metrics['weight']}kg"),
                      _buildMetricCol(
                          "Ideal Weight", "${analysis['idealWeight']}kg"),
                      _buildMetricCol("BMI", "${analysis['bmi']}"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Suggested Plan Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Generated Plan",
                          style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.darkBlue)),
                      const Icon(Icons.check_circle,
                          color: AppTheme.primaryGreen),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.restaurant_menu_rounded,
                          color: Colors.blue),
                    ),
                    title: Text("My Diet and Activity Plan",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                    subtitle: Text("Full 7-day AI curated schedule",
                        style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DietPlanDetailScreen())),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            _buildTrackerIconRow(Icons.directions_run_rounded, "Step Count",
                "0 steps", Colors.blue),
            _buildTrackerIconRow(
                Icons.bloodtype_rounded, "Log Sugar", "110 mg/dL", Colors.red),
            _buildTrackerIconRow(Icons.monitor_heart_rounded, "Heart Rate",
                "72 bpm", Colors.pink),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
        Text(value,
            style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkBlue)),
      ],
    );
  }

  Widget _buildTrackerIconRow(
      IconData icon, String title, String val, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Text(title,
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700, color: AppTheme.darkBlue)),
          const Spacer(),
          Text(val,
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800, color: color)),
          const SizedBox(width: 8),
          const Icon(Icons.add, size: 20, color: Colors.grey),
        ],
      ),
    );
  }

  void _showAddCalorieDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Log Meal Calories", style: GoogleFonts.outfit()),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration:
              const InputDecoration(hintText: "Enter calories (e.g. 350)"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final uid = auth.userId ?? "test_user_123";
              Provider.of<DietProvider>(context, listen: false)
                  .addCalories(uid, int.parse(controller.text));
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
