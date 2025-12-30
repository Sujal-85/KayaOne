import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:pinput/pinput.dart';
import 'package:kayaone/presentation/auth/personal_info_screen.dart';
import 'package:kayaone/data/services/auth_service.dart';
import 'package:kayaone/state/auth_provider.dart';
import 'package:kayaone/presentation/home/home_screen.dart';
import 'package:kayaone/core/localization/app_localizations.dart';

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
          SnackBar(
              content: Text(AppLocalizations.of(context)
                      ?.translate('invalid_otp_error') ??
                  "Invalid OTP or Server Error. Please try again."),
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
    var appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.milkyWhite,
      body: LayoutBuilder(builder: (context, constraints) {
        final isSmall =
            constraints.maxWidth < 400 || constraints.maxHeight < 700;
        final lottieHeight = isSmall ? 150.0 : 220.0;
        final pinSize = isSmall ? 40.0 : 50.0;
        final pinHeight = isSmall ? 45.0 : 56.0;
        final titleSize = isSmall ? 24.0 : 28.0;
        final buttonHeight = isSmall ? 50.0 : 64.0;
        final buttonTextSize = isSmall ? 16.0 : 18.0;

        return Stack(
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
                      height: lottieHeight,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 10),

                    // Glassmorphic Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: EdgeInsets.all(isSmall ? 20 : 32),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                appLocalizations?.translate('verify_phone') ??
                                    "Verify Phone",
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.darkBlue,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "${appLocalizations?.translate('enter_code_sent') ?? 'Enter the code sent to'}\n${widget.phoneNumber}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      AppTheme.darkBlue.withValues(alpha: 0.6),
                                  fontSize: isSmall ? 13 : 15,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 40),
                              Pinput(
                                length: 6,
                                controller: _otpController,
                                focusNode: _focusNode,
                                autofillHints: const [
                                  AutofillHints.oneTimeCode
                                ],
                                defaultPinTheme: PinTheme(
                                  width: pinSize,
                                  height: pinHeight,
                                  textStyle: TextStyle(
                                    fontSize: isSmall ? 18 : 22,
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
                                  width: pinSize,
                                  height: pinHeight,
                                  textStyle: TextStyle(
                                    fontSize: isSmall ? 18 : 22,
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
                                    minimumSize:
                                        Size(double.infinity, buttonHeight),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    appLocalizations?.translate('confirm') ??
                                        "Confirm",
                                    style: TextStyle(
                                        fontSize: buttonTextSize,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${appLocalizations?.translate('didnt_receive_code') ?? "Didn't receive code?"} ",
                                    style: TextStyle(
                                        color: AppTheme.darkBlue
                                            .withValues(alpha: 0.6)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Resend logic
                                    },
                                    child: Text(
                                      appLocalizations?.translate('resend') ??
                                          "Resend",
                                      style: const TextStyle(
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
        );
      }),
    );
  }
}
