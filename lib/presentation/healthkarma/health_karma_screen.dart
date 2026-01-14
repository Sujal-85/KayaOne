import 'package:flutter/material.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/state/health_karma_provider.dart';
import 'package:kayaone/data/models/health_karma.dart';
import 'package:kayaone/presentation/healthkarma/question_flow_screen.dart';
import 'package:kayaone/presentation/doctors/doctor_listing_screen.dart';
import 'package:kayaone/presentation/diet/diet_router.dart';
import 'package:kayaone/state/auth_provider.dart';
import 'package:kayaone/core/localization/app_localizations.dart';

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
    var appLocalizations = AppLocalizations.of(context);

    if (result == null) {
      return _buildEmptyState(context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          image: DecorationImage(
            image: AssetImage('assets/images/home_bg_leaves.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Custom Header area
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                child: Row(
                  children: [
                    Text(
                      appLocalizations?.translate('health_karma_status') ??
                          "Health Status",
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color.fromARGB(255, 250, 250, 250),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: AppTheme.primaryGreen),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                  child: Column(
                    children: [
                      // Score Header
                      _buildHeader(result, context),

                      const SizedBox(height: 32),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          appLocalizations?.translate('probable_risks') ??
                              "Your Probable Risks",
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tabs
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          labelColor: AppTheme.primaryGreen,
                          unselectedLabelColor: Colors.grey.shade600,
                          labelStyle: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700, fontSize: 13),
                          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600, fontSize: 13),
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          tabs: [
                            Tab(
                                text: appLocalizations
                                        ?.translate('high_medium') ??
                                    "High & Medium"),
                            Tab(
                                text: appLocalizations?.translate('low_risk') ??
                                    "Low Risk"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Risk Items
                      _buildRiskList(result),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: () => provider.resetQuiz(),
          backgroundColor: AppTheme.primaryGreen,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          label: Text(
            appLocalizations?.translate('retake_analysis') ?? "Retake Analysis",
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userName ?? 'User';
    final firstName = userName.split(' ').first;
    var appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "HealthKarma",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home_bg_leaves.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  const Icon(Icons.keyboard_arrow_down,
                                      size: 24),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appLocalizations
                                        ?.translate('welcome_kayaone') ??
                                    "Welcome to kayaone!",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.1, end: 0),

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
                          child: LayoutBuilder(builder: (context, constraints) {
                            final isSmall = constraints.maxWidth < 360;
                            final iconSize = isSmall ? 60.0 : 80.0;
                            final fontSizeQuestion = isSmall ? 32.0 : 40.0;

                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appLocalizations?.translate(
                                                'find_your_healthkarma') ??
                                            "Find Your HealthKarma",
                                        style: GoogleFonts.outfit(
                                          fontSize: isSmall ? 18 : 20,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        appLocalizations?.translate(
                                                'healthkarma_desc') ??
                                            "Your HealthKarma score will help us understand your health status better",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: isSmall ? 13 : 14,
                                          color: Colors.grey.shade600,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const QuestionFlowScreen()),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color.fromARGB(255, 75, 169, 12),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          elevation: 0,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                appLocalizations?.translate(
                                                        'calculate_score') ??
                                                    "Calculate Your Score",
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.chevron_right,
                                                size: 18),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: isSmall ? 12 : 16),
                                // Styled "?" Icon
                                Container(
                                  width: iconSize,
                                  height: iconSize,
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
                                  child: Center(
                                    child: Text(
                                      "?",
                                      style: TextStyle(
                                        fontSize: fontSizeQuestion,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF00897B),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          })
                              .animate()
                              .fadeIn(delay: 100.ms)
                              .slideY(begin: 0.1, end: 0),
                        ),
                        const SizedBox(height: 40),

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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(
                                      color: Color.fromARGB(255, 75, 169, 12)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  appLocalizations?.translate('track_orders') ??
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
                                  backgroundColor: const Color.fromARGB(255, 68, 61, 132),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  appLocalizations?.translate('explore') ??
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
                          appLocalizations?.translate('your_doctor') ??
                              "Your Doctor",
                          appLocalizations?.translate('consult_doctor_desc') ??
                              "Consult specialist doctors from\nthe comforts of your home",
                          const Color(0xFFFFF3F5), // Light pink
                          const Color(0xFFFF5277), // Deep pink
                          Icons.medical_services_outlined,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DoctorListingScreen()),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 500.ms)
                            .slideY(begin: 0.1, end: 0),

                        const SizedBox(height: 16),

                        _buildServiceRow(
                          appLocalizations?.translate('your_dietitian') ??
                              "Your Dietitian",
                          appLocalizations?.translate('book_diet_desc') ??
                              "Book Diet Consultation\n@ Rs.299 only",
                          const Color(0xFFF1FAF2), // Light green
                          const Color(0xFF4CAF50), // Deep green
                          Icons.scale_outlined,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DietRouter()),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 600.ms)
                            .slideY(begin: 0.1, end: 0),

                        const SizedBox(
                            height: 100), // Bottom padding for navbar
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    var appLocalizations = AppLocalizations.of(context);

    final color = result.score >= 70
        ? Colors.green.shade400
        : (result.score >= 40 ? Colors.orange.shade400 : Colors.red.shade400);

    return LayoutBuilder(builder: (context, constraints) {
      final isSmall = constraints.maxWidth < 360;
      final progressSize = isSmall ? 160.0 : 220.0;
      final fontSizeScore = isSmall ? 48.0 : 64.0;

      return Container(
        decoration: const BoxDecoration(
          color: Colors.transparent, // Transparent to show background
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: isSmall ? 48 : 60),
            Text(
              "Hi, $firstName",
              style: GoogleFonts.plusJakartaSans(
                  fontSize: isSmall ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.teal.shade700),
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: progressSize,
                  height: progressSize,
                  child: CircularProgressIndicator(
                    value: result.score / 100,
                    strokeWidth: isSmall ? 10 : 15,
                    backgroundColor: Colors.teal.shade50,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ).animate().rotate(duration: 2.seconds),
                Column(
                  children: [
                    Text(
                      "${result.score}%",
                      style: GoogleFonts.outfit(
                          fontSize: fontSizeScore,
                          fontWeight: FontWeight.w900,
                          color: Colors.teal.shade900),
                    ).animate().scale(),
                    Text(
                      appLocalizations?.translate('overall_score') ??
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
    });
  }

  Widget _buildRiskList(HealthKarmaResult result) {
    final risks = result.riskLevels.entries.toList();
    var appLocalizations = AppLocalizations.of(context);

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
              "${risk.value} ${appLocalizations?.translate('risk') ?? 'Risk'}",
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
    var appLocalizations = AppLocalizations.of(context);
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
                "${appLocalizations?.translate('potential_factors') ?? 'Potential key factors contributing to'} \n${riskName.toUpperCase().replaceAll('_', ' ')}",
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
                  child:
                      Text(appLocalizations?.translate('got_it') ?? "Got it"),
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
    IconData icon;
    Color color;

    switch (level) {
      case 'High':
        icon = Icons.warning_rounded;
        color = Colors.red;
        break;
      case 'Medium':
        icon = Icons.info_outline_rounded;
        color = Colors.orange;
        break;
      default:
        icon = Icons.check_circle_outline_rounded;
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color),
    );
  }
}
