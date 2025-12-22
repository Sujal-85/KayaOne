import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:medinest/state/diet_provider.dart';

class DietPlanDetailScreen extends StatelessWidget {
  const DietPlanDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dietProvider = Provider.of<DietProvider>(context);
    final plan = dietProvider.dietData?['currentPlan'];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text("Your 7-Day Plan",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: plan == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: plan['days'].length,
              itemBuilder: (context, index) {
                final day = plan['days'][index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day['dayName'],
                        style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryGreen),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(day['meals'].length, (mIndex) {
                        final meal = day['meals'][mIndex];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10)
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Icon(_getMealIcon(meal['mealType']),
                                    color: Colors.orange),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(meal['mealType'],
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w700)),
                                    Text(meal['foodName'],
                                        style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.darkBlue)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("${meal['calories']} kcal",
                                      style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primaryGreen)),
                                  Text(
                                      "P: ${meal['protein']}g | C: ${meal['carbs']}g",
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
    );
  }

  IconData _getMealIcon(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny_outlined;
      case 'lunch':
        return Icons.lunch_dining_rounded;
      case 'dinner':
        return Icons.dark_mode_outlined;
      default:
        return Icons.apple_rounded;
    }
  }
}
