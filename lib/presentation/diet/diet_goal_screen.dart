import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/state/diet_provider.dart';
import 'package:kayaone/state/auth_provider.dart';
import 'package:kayaone/presentation/diet/diet_dashboard_screen.dart';

class DietGoalScreen extends StatefulWidget {
  const DietGoalScreen({super.key});

  @override
  State<DietGoalScreen> createState() => _DietGoalScreenState();
}

class _DietGoalScreenState extends State<DietGoalScreen> {
  String _selectedGoal = "Maintain Weight";
  String _selectedFood = "Non Vegetarian";
  String _selectedActivity = "Moderate";

  @override
  Widget build(BuildContext context) {
    final dietProvider = Provider.of<DietProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text("Health Goal",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Weight Management"),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildGoalCard(Icons.scale_rounded, "Weight Loss",
                    _selectedGoal == "Weight Loss"),
                _buildGoalCard(Icons.accessibility_new_rounded,
                    "Maintain Weight", _selectedGoal == "Maintain Weight"),
                _buildGoalCard(Icons.fitness_center_rounded, "Muscle Building",
                    _selectedGoal == "Muscle Building"),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle("Food Choice"),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildFoodCard("Vegetarian", _selectedFood == "Vegetarian"),
                _buildFoodCard(
                    "Non Vegetarian", _selectedFood == "Non Vegetarian"),
                _buildFoodCard(
                    "Vegetarian + Egg", _selectedFood == "Vegetarian + Egg"),
                _buildFoodCard("Vegan", _selectedFood == "Vegan"),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle("Activity"),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActivityCard(Icons.airline_seat_recline_extra_rounded,
                    "Sedentary", _selectedActivity == "Sedentary"),
                _buildActivityCard(Icons.directions_walk_rounded, "Light",
                    _selectedActivity == "Light"),
                _buildActivityCard(Icons.directions_run_rounded, "Moderate",
                    _selectedActivity == "Moderate"),
                _buildActivityCard(Icons.bolt_rounded, "Active",
                    _selectedActivity == "Active"),
              ],
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () async {
                final uid = authProvider.userId ?? "test_user_123";
                dietProvider.updateGoals(
                    wg: _selectedGoal,
                    fc: _selectedFood,
                    al: _selectedActivity);
                final success = await dietProvider.saveProfile(uid);
                if (success) {
                  // Trigger AI generation if no plan exists or force update
                  await dietProvider.generateNewPlan(uid);
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DietDashboardScreen()),
                      (route) => route.isFirst,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: dietProvider.isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2)),
                        const SizedBox(width: 12),
                        Text("Generating AI Plan...",
                            style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Create Plan",
                            style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(width: 8),
                        const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.outfit(
            fontSize: 18, fontWeight: FontWeight.w800, color: Colors.blue));
  }

  Widget _buildGoalCard(IconData icon, String title, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = title),
      child: Container(
        width: (MediaQuery.of(context).size.width - 72) / 3,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.blue : AppTheme.darkBlue)),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(String title, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFood = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? Colors.orange : Colors.transparent, width: 2),
        ),
        child: Text(title,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.orange : AppTheme.darkBlue)),
      ),
    );
  }

  Widget _buildActivityCard(IconData icon, String title, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedActivity = title),
      child: Container(
        width: (MediaQuery.of(context).size.width - 72) / 3,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
              width: 2),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? AppTheme.primaryGreen : Colors.grey,
                size: 32),
            const SizedBox(height: 8),
            Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : AppTheme.darkBlue)),
          ],
        ),
      ),
    );
  }
}
