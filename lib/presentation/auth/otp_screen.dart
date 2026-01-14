import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:pinput/pinput.dart';
import 'package:kayaone/presentation/language/language_screen.dart';
import 'package:kayaone/data/services/auth_service.dart';
import 'package:kayaone/state/auth_provider.dart';
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

  // Timer related
  Timer? _timer;
  int _start = 30;
  bool _isResendEnabled = false;
  String _currentVerificationId = "";

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _startTimer();
    _listenForAutoVerification();
  }

  void _startTimer() {
    setState(() {
      _isResendEnabled = false;
      _start = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isResendEnabled = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _authStateSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOTP(String otp) async {
    if (otp.length < 6) return;

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _currentVerificationId,
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

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution handling if needed, though usually handled by stream
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(e.message ?? "Verification Failed"),
                backgroundColor: Colors.redAccent),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _currentVerificationId = verificationId;
            });
            _startTimer();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("OTP Resent Successfully"),
                  backgroundColor: Colors.green),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _currentVerificationId = verificationId;
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error resending OTP: $e"),
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
      builder: (context) {
        // Auto-navigate after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (_) =>
                      LanguageScreen(isRegistrationComplete: isComplete)),
              (route) => false,
            );
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors
                      .green, // Using standard green for safety or AppTheme.primaryGreen if sure
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Verified!",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_images/image2.png',
              fit: BoxFit.cover,
            ),
          ),
          // Black Drop Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // No Lottie, just clean text
                    Text(
                      appLocalizations?.translate('verify_phone') ??
                          "Verify Phone",
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${appLocalizations?.translate('enter_code_sent') ?? 'Enter the code sent to'}\n${widget.phoneNumber}",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // OTP Input
                    Pinput(
                      length: 6,
                      controller: _otpController,
                      focusNode: _focusNode,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      defaultPinTheme: PinTheme(
                        width: 50,
                        height: 60,
                        textStyle: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Changed to black
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(alpha: 0.9), // Increased opacity
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.2,
                          ),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 50,
                        height: 60,
                        textStyle: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Changed to black
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white, // Pure white for focus
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryGreen,
                            width: 2,
                          ),
                        ),
                      ),
                      onCompleted: (pin) => _verifyOTP(pin),
                    ),

                    const SizedBox(height: 48),

                    if (_isLoading)
                      const CircularProgressIndicator(color: Colors.white)
                    else
                      ElevatedButton(
                        onPressed: () => _verifyOTP(_otpController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 64),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          appLocalizations?.translate('confirm') ?? "Confirm",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${appLocalizations?.translate('didnt_receive_code') ?? "Didn't receive code?"} ",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: _isResendEnabled ? _resendOTP : null,
                          child: Text(
                            _isResendEnabled
                                ? (appLocalizations?.translate('resend') ??
                                    "Resend")
                                : "${appLocalizations?.translate('resend') ?? "Resend"} in ${_start}s",
                            style: TextStyle(
                              color: _isResendEnabled
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: _isResendEnabled
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                              decorationColor: Colors.white,
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
    );
  }
}
