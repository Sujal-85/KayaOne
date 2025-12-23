import 'package:flutter/material.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:medinest/presentation/home/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:medinest/state/health_karma_provider.dart';
import 'package:medinest/data/models/health_karma.dart';
import 'package:medinest/presentation/healthkarma/question_flow_screen.dart';
import 'package:medinest/presentation/doctors/doctor_listing_screen.dart';
import 'package:medinest/presentation/diet/diet_router.dart';
import 'package:medinest/state/auth_provider.dart';

class HealthKarmaScreen extends StatefulWidget {
  const HealthKarmaScreen({super.key});

  @override
  State<HealthKarmaScreen> createState() => _HealthKarmaScreenState();
}

class _HealthKarmaScreenState extends State<HealthKarmaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthKarmaProvider>(context);
    final result = provider.result;

    if (result == null) {
      return _buildEmptyState(context);
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.5),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.teal),
              ),
              onPressed: () async {
                final didPop = await Navigator.of(context).maybePop();
                if (!didPop) {
                  HomeScreenState.of(context)?.setIndex(0);
                }
              },
            ),
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.teal.shade50,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(result, context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Probable Risks",
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.teal.shade900,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tabs
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.teal.shade900,
                      unselectedLabelColor: Colors.teal.shade400,
                      labelStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800),
                      tabs: const [
                        Tab(text: "High & Medium"),
                        Tab(text: "Low Risk"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Risk Items
                  _buildRiskList(result),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => provider.resetQuiz(),
        backgroundColor: Colors.teal.shade400,
        label: const Text("Retake Analysis"),
        icon: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userName ?? 'User';
    final firstName = userName.split(' ').first;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Custom Header with Back Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "HealthKarma",
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Color(0xFF1A1A1A)),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          HomeScreenState.of(context)?.setIndex(0);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 1. Greeting Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Hi, $firstName",
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, size: 24),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Welcome to HealthKarma!",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // 2. Calculate Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Find Your HealthKarma",
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Your HealthKarma score will help us understand your health status better",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const QuestionFlowScreen()),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00897B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "Calculate Your Score",
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Styled "?" Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(4, 4),
                            ),
                            const BoxShadow(
                              color: Colors.white,
                              blurRadius: 10,
                              offset: Offset(-4, -4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "?",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF00897B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 40),

                // 3. Health Supplements Section
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Flexible(
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Text(
                //             "Health Supplements",
                //             style: GoogleFonts.outfit(
                //               fontSize: 18,
                //               fontWeight: FontWeight.w800,
                //               color: const Color(0xFF1A1A1A),
                //             ),
                //           ),
                //           Text(
                //             "Choose from a wide range for healthy living",
                //             style: GoogleFonts.plusJakartaSans(
                //               fontSize: 12,
                //               color: Colors.grey.shade600,
                //               fontWeight: FontWeight.w500,
                //             ),
                //             overflow: TextOverflow.ellipsis,
                //           ),
                //         ],
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     // HerbVed Logo
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.end,
                //       children: [
                //         Text(
                //           "Herbवेद⁺",
                //           style: GoogleFonts.outfit(
                //             fontSize: 20,
                //             fontWeight: FontWeight.w900,
                //             color: const Color(0xFF00897B),
                //           ),
                //         ),
                //         Text(
                //           "by Healthians",
                //           style: GoogleFonts.plusJakartaSans(
                //             fontSize: 10,
                //             color: const Color(0xFF00897B),
                //             fontWeight: FontWeight.w700,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ],
                // ).animate().fadeIn(delay: 200.ms),

                // const SizedBox(height: 20),

                // Product Cards Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildSupplementCard(
                        "IMMUNO-PLUS",
                        "₹1095",
                        "₹2299",
                        "assets/images/med_product_1.png",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSupplementCard(
                        "NUTRI-BOOST",
                        "₹664",
                        "₹1476",
                        "assets/images/med_product_2.png",
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 24),

                // Action Buttons for HerbVed
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF00897B)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          "Track Orders",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF00897B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00897B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          "Explore",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 48),

                // 4. Service Rows
                _buildServiceRow(
                  "Your Doctor",
                  "Consult specialist doctors from\nthe comforts of your home",
                  const Color(0xFFFFF3F5), // Light pink
                  const Color(0xFFFF5277), // Deep pink
                  Icons.medical_services_outlined,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DoctorListingScreen()),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 16),

                _buildServiceRow(
                  "Your Dietitian",
                  "Book Diet Consultation\n@ Rs.299 only",
                  const Color(0xFFF1FAF2), // Light green
                  const Color(0xFF4CAF50), // Deep green
                  Icons.scale_outlined,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DietRouter()),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 100), // Bottom padding for navbar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupplementCard(
      String title, String price, String oldPrice, String image) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.teal.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.medication_liquid_rounded,
                    size: 48,
                    color: const Color(0xFF00897B).withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                price,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                oldPrice,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(String title, String subtitle, Color bgColor,
      Color iconColor, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(width: 12),
            Icon(Icons.keyboard_double_arrow_right_rounded,
                size: 20, color: iconColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(HealthKarmaResult result, BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userName ?? 'User';
    final firstName = userName.split(' ').first;

    final color = result.score >= 70
        ? Colors.green.shade400
        : (result.score >= 40 ? Colors.orange.shade400 : Colors.red.shade400);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Text(
            "Hi, $firstName",
            style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.teal.shade700),
          ),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value: result.score / 100,
                  strokeWidth: 15,
                  backgroundColor: Colors.teal.shade50,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ).animate().rotate(duration: 2.seconds),
              Column(
                children: [
                  Text(
                    "${result.score}%",
                    style: GoogleFonts.outfit(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: Colors.teal.shade900),
                  ).animate().scale(),
                  Text(
                    "Overall Score",
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskList(HealthKarmaResult result) {
    final risks = result.riskLevels.entries.toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: risks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final risk = risks[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: _getRiskIcon(risk.value),
            title: Text(
              risk.key.toUpperCase().replaceAll('_', ' '),
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800, color: Colors.teal.shade900),
            ),
            subtitle: Text(
              "${risk.value} Risk",
              style: TextStyle(
                  color: _getRiskColor(risk.value),
                  fontWeight: FontWeight.w700),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRiskDetails(
                context, risk.key, result.explanations[risk.key] ?? []),
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideX();
      },
    );
  }

  void _showRiskDetails(
      BuildContext context, String riskName, List<String> explanations) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Potential key factors contributing to \n${riskName.toUpperCase().replaceAll('_', ' ')}",
                style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.teal.shade900),
              ),
              const SizedBox(height: 24),
              ...explanations.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.teal),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(e,
                                style:
                                    GoogleFonts.plusJakartaSans(fontSize: 16))),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Got it"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getRiskColor(String level) {
    switch (level) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Widget _getRiskIcon(String level) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _getRiskColor(level).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.warning_amber_rounded, color: _getRiskColor(level)),
    );
  }
}
