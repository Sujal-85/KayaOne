import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:pinput/pinput.dart';
import 'package:medinest/presentation/auth/personal_info_screen.dart';
import 'package:medinest/data/services/auth_service.dart';
import 'package:medinest/state/auth_provider.dart';
import 'package:medinest/presentation/home/home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _otpController.text = "123456"; // Pre-filled for development
    _listenForAutoVerification();
  }

  void _listenForAutoVerification() {
    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null && mounted && !_isLoading) {
        // Firebase auto-verified the SMS and signed in the user
        _handleSuccessfulLogin();
      }
    });
  }

  Future<void> _handleSuccessfulLogin() async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      final authData = await authService.login(widget.phoneNumber);

      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authData != null) {
          final isProfileComplete =
              authData['user']['isProfileComplete'] ?? false;
          authProvider.login(
            widget.phoneNumber,
            name: authData['user']['name'],
            isProfileComplete: isProfileComplete,
          );
          _showSuccessDialog(isComplete: isProfileComplete);
        } else {
          authProvider.login(widget.phoneNumber);
          _showSuccessDialog(isComplete: false);
        }
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _verifyOTP(String otp) async {
    if (otp.length < 6) return;

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // Backend Logic
      final authService = AuthService();
      final authData = await authService.login(widget.phoneNumber);

      if (mounted) {
        setState(() => _isLoading = false);

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authData != null) {
          final isProfileComplete =
              authData['user']['isProfileComplete'] ?? false;
          authProvider.login(
            widget.phoneNumber,
            name: authData['user']['name'],
            isProfileComplete: isProfileComplete,
          );

          _showSuccessDialog(isComplete: isProfileComplete);
        } else {
          authProvider.login(widget.phoneNumber);
          _showSuccessDialog(isComplete: false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _otpController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Invalid OTP or Server Error. Please try again."),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _showSuccessDialog({bool isComplete = false}) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/done.json',
              repeat: false,
              onLoaded: (composition) {
                Future.delayed(composition.duration, () {
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => isComplete
                              ? const HomeScreen()
                              : const PersonalInfoScreen()),
                      (route) => false,
                    );
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.milkyWhite,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(color: AppTheme.milkyWhite),
          ),

          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: AppTheme.darkBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Lottie.asset(
                    'assets/lottie/security.json',
                    height: 220,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 10),

                  // Glassmorphic Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Verify Phone",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.darkBlue,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Enter the code sent to\n${widget.phoneNumber}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.darkBlue.withValues(alpha: 0.6),
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Pinput(
                              length: 6,
                              controller: _otpController,
                              focusNode: _focusNode,
                              autofillHints: const [AutofillHints.oneTimeCode],
                              defaultPinTheme: PinTheme(
                                width: 50,
                                height: 56,
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.darkBlue,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                              ),
                              focusedPinTheme: PinTheme(
                                width: 50,
                                height: 56,
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.darkBlue,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppTheme.primaryGreen, width: 2),
                                ),
                              ),
                              onCompleted: (pin) => _verifyOTP(pin),
                            ),
                            const SizedBox(height: 40),
                            if (_isLoading)
                              const CircularProgressIndicator(
                                  color: AppTheme.primaryGreen)
                            else
                              ElevatedButton(
                                onPressed: () =>
                                    _verifyOTP(_otpController.text),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.darkBlue,
                                  minimumSize: const Size(double.infinity, 64),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Confirm",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Didn't receive code? ",
                                  style: TextStyle(
                                      color: AppTheme.darkBlue
                                          .withValues(alpha: 0.6)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Placeholder for resend logic
                                    // This is where you would typically call a resend OTP function.
                                    // Example:
                                    // if (mounted) {
                                    //   setState(() {
                                    //     _isLoading = true;
                                    //   });
                                    //   // Call your resend OTP service
                                    //   // await authService.resendOtp(widget.phoneNumber);
                                    //   if (mounted) {
                                    //     setState(() {
                                    //       _isLoading = false;
                                    //     });
                                    //     ScaffoldMessenger.of(context).showSnackBar(
                                    //       const SnackBar(content: Text("OTP Resent!")),
                                    //     );
                                    //   }
                                    // }
                                  },
                                  child: const Text(
                                    "Resend",
                                    style: TextStyle(
                                      color: AppTheme.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
