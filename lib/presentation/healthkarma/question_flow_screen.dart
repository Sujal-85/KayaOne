import 'package:flutter/material.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:medinest/state/health_karma_provider.dart';
import 'package:medinest/data/models/health_karma.dart';
import 'package:medinest/presentation/healthkarma/ai_analysis_screen.dart';

class QuestionFlowScreen extends StatefulWidget {
  const QuestionFlowScreen({super.key});

  @override
  State<QuestionFlowScreen> createState() => _QuestionFlowScreenState();
}

class _QuestionFlowScreenState extends State<QuestionFlowScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthKarmaProvider>(context);
    final question = provider.questions[provider.currentQuestionIndex];
    final progress =
        (provider.currentQuestionIndex + 1) / provider.questions.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress Bar
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Step ${provider.currentQuestionIndex + 1} of ${provider.questions.length}",
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.teal.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.teal),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.teal.shade50,
                        valueColor:
                            AlwaysStoppedAnimation(Colors.teal.shade400),
                        minHeight: 8,
                      ),
                    ).animate().scale(delay: 200.ms),
                  ],
                ),
              ),

              Expanded(
                child: PageView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.questions.length,
                  itemBuilder: (context, index) {
                    return _buildQuestionCard(question, provider);
                  },
                ),
              ),

              // Navigation
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (provider.currentQuestionIndex > 0)
                      TextButton(
                        onPressed: provider.previousQuestion,
                        child: Text(
                          "Previous",
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.teal.shade600,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 80),
                    ElevatedButton(
                      onPressed: () {
                        if (provider.currentQuestionIndex ==
                            provider.questions.length - 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AIAnalysisScreen()),
                          );
                        } else {
                          provider.nextQuestion();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        provider.currentQuestionIndex ==
                                provider.questions.length - 1
                            ? "Finish"
                            : "Next",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
      HealthKarmaQuestion question, HealthKarmaProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.teal.shade600,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn().slideX(),
          const SizedBox(height: 8),
          Text(
            question.questionText,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.teal.shade900,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(),
          const SizedBox(height: 40),

          const SizedBox(height: 20),

          // Options
          Expanded(
            child: ListView.separated(
              itemCount: question.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final option = question.options[idx];
                final isSelected = provider.userResponses[question.id] ==
                    option; // Simplified for single select

                return InkWell(
                  onTap: () => provider.setResponse(question.id, option),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal.shade400 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.teal.shade400
                            : Colors.teal.shade50,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.teal.shade900,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.white),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
