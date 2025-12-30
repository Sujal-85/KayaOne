import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:kayaone/core/theme/app_theme.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/loading_animation.json',
                height: 200,
              ),
              const SizedBox(height: 40),
              const Text(
                "No Internet Connection",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkBlue,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Please check your internet settings and try again to continue.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () async {
                  var connectivityResult =
                      await (Connectivity().checkConnectivity());
                  if (connectivityResult != ConnectivityResult.none) {
                    if (context.mounted) Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Retry"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 56),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  // In a real app, use AppSettings or similar to open settings
                },
                icon: const Icon(Icons.settings_rounded),
                label: const Text("Open Settings"),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accentGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
