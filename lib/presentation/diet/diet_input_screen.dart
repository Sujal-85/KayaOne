import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:medinest/state/diet_provider.dart';
import 'package:medinest/presentation/diet/diet_goal_screen.dart';

class DietInputScreen extends StatefulWidget {
  const DietInputScreen({super.key});

  @override
  State<DietInputScreen> createState() => _DietInputScreenState();
}

class _DietInputScreenState extends State<DietInputScreen> {
  final TextEditingController _weightController =
      TextEditingController(text: "70");
  final TextEditingController _feetController =
      TextEditingController(text: "5");
  final TextEditingController _inchController =
      TextEditingController(text: "8");
  String _selectedRegion = "India";
  String _medicalCondition = "None";

  @override
  Widget build(BuildContext context) {
    final dietProvider = Provider.of<DietProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.darkBlue),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Create Your Diet Plan",
              style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkBlue),
            ),
            const SizedBox(height: 8),
            Text(
              "Get your 7 days diet plan along with\nfood recommendations curated by experts.",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 60),
            _buildInputRow(
              icon: Icons.monitor_weight_outlined,
              label: "Your Weight",
              controller: _weightController,
              unit: "Kg",
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInputRow(
                    icon: Icons.height_rounded,
                    label: "Feet",
                    controller: _feetController,
                    unit: "ft.",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputRow(
                    icon: Icons.height_rounded,
                    label: "Inch",
                    controller: _inchController,
                    unit: "in.",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDropdownRow(
              icon: Icons.location_on_outlined,
              label: "Select Region",
              value: _selectedRegion,
              items: ["India", "USA", "Europe", "Others"],
              onChanged: (val) => setState(() => _selectedRegion = val!),
            ),
            const SizedBox(height: 24),
            _buildDropdownRow(
              icon: Icons.medical_services_outlined,
              label: "Medical Condition",
              value: _medicalCondition,
              items: ["None", "Diabetes", "Hypertension", "PCOS", "Thyroid"],
              onChanged: (val) => setState(() => _medicalCondition = val!),
            ),
            const SizedBox(height: 80),
            ElevatedButton(
              onPressed: () {
                dietProvider.updateMetrics(
                  w: double.tryParse(_weightController.text),
                  ft: int.tryParse(_feetController.text),
                  inc: int.tryParse(_inchController.text),
                  reg: _selectedRegion,
                );
                dietProvider.medicalConditions = [_medicalCondition];
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DietGoalScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Next",
                      style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 18, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(
      {required IconData icon,
      required String label,
      required TextEditingController controller,
      required String unit}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: label,
                hintStyle: GoogleFonts.plusJakartaSans(
                    color: Colors.grey, fontSize: 14),
              ),
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700, color: AppTheme.darkBlue),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(10)),
            child: Text(unit,
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(
      {required IconData icon,
      required String label,
      required String value,
      required List<String> items,
      required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: items
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e,
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.darkBlue))))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
