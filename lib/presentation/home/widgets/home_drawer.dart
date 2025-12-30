import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/presentation/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/state/auth_provider.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(0)),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  icon: Icons.grid_view_rounded,
                  title: "Categories",
                  onTap: () {},
                ),
                _buildDrawerItem(
                  icon: Icons.article_outlined,
                  title: "Blog",
                  onTap: () {},
                ),
                _buildDrawerItem(
                  icon: Icons.local_shipping_outlined,
                  title: "Track Order",
                  onTap: () {},
                ),
                _buildDrawerItem(
                  icon: Icons.image_outlined,
                  title: "Media",
                  onTap: () {},
                ),
                _buildDrawerItem(
                  icon: Icons.medical_services_outlined,
                  title: "Consult a Doctor",
                  onTap: () {},
                ),
                const Divider(height: 32, thickness: 0.5),
                _buildDrawerItem(
                  icon: Icons.star_border_rounded,
                  title: "Rate Us",
                  onTap: () {},
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline_rounded,
                  title: "About Us",
                  onTap: () {},
                ),
                _buildDrawerItem(
                  icon: Icons.phone_outlined,
                  title: "Contact Us",
                  onTap: () {},
                ),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return _buildDrawerItem(
                      icon: Icons.logout_rounded,
                      title: auth.isLoggedIn ? "Logout" : "Login/Register",
                      onTap: () async {
                        if (auth.isLoggedIn) {
                          await auth.logout();
                        }
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userName ?? "Guest !";

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userName,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkBlue,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                "HealthKarma Coins",
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                "0", // Verify if we have coin field in provider
                style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: AppTheme.primaryGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 22),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      dense: true,
      minLeadingWidth: 20,
    );
  }
}
