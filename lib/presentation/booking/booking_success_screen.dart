import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:medinest/presentation/home/home_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SizedBox(
                height: 250,
                child: Lottie.asset(
                  'assets/lottie/done.json',
                  repeat: false,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.check_circle_rounded,
                        color: Colors.green, size: 150);
                  },
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Booking Successful!",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor),
              ),
              const SizedBox(height: 16),
              const Text(
                "Your test has been scheduled. Our phlebotomist will contact you soon.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text("Back to Home"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {},
                child: const Text("View Order Details",
                    style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
