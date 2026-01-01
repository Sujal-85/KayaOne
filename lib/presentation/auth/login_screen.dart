import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:kayaone/state/auth_provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/presentation/auth/otp_screen.dart';

import 'package:kayaone/core/localization/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isVerifying = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() {
        _isFocused = _phoneFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handlePhoneVerification() async {
    FocusScope.of(context).unfocus();
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.translate('invalid_phone') ??
                "Please enter a valid phone number",
          ),
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${_phoneController.text}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isVerifying = false);
          String errorMsg =
              AppLocalizations.of(context)?.translate('verification_failed') ??
                  "Verification Failed";
          if (e.code == 'invalid-phone-number') {
            errorMsg = AppLocalizations.of(context)
                    ?.translate('invalid_phone_error') ??
                "The provided phone number is not valid.";
          } else if (e.code == 'too-many-requests') {
            errorMsg =
                AppLocalizations.of(context)?.translate('blocked_error') ??
                    "Blocked due to unusual activity. Try again later.";
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(errorMsg), backgroundColor: Colors.redAccent),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() => _isVerifying = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                phoneNumber: '+91${_phoneController.text}',
                verificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() => _isVerifying = false);
      String errorMsg =
          AppLocalizations.of(context)?.translate('server_error') ?? 'Error: ';

      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-app-credential') {
          errorMsg =
              "App verification failed. SHA-1/SHA-256 keys missing in Firebase Console.";
        } else if (e.code == 'invalid-phone-number') {
          errorMsg = "The provided phone number is not valid.";
        } else if (e.code == 'too-many-requests') {
          errorMsg = "Blocked due to unusual activity. Try again later.";
        } else {
          errorMsg += e.message ?? e.code;
        }
      } else {
        errorMsg += e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.milkyWhite,
      body: LayoutBuilder(builder: (context, constraints) {
        final isSmallHeight = constraints.maxHeight < 700;
        final logoSize = isSmallHeight ? 48.0 : 64.0;
        final titleSize = isSmallHeight ? 28.0 : 32.0;

        return Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                'assets/images/splash_images/image1.png',
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 40.0),
                  child: AutofillGroup(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo & App Name
                        Container(
                          padding: const EdgeInsets.all(
                              16), // Increased padding for better breathing room
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1),
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: logoSize,
                            width: logoSize,
                            fit: BoxFit.contain, // Ensure logo isn't cropped
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          AppLocalizations.of(context)?.translate('app_name') ??
                              "KAYAONE",
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Welcome Text
                        Text(
                          AppLocalizations.of(context)
                                  ?.translate('welcome_home') ??
                              "Welcome Back",
                          style: GoogleFonts.outfit(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)
                                  ?.translate('join_community') ??
                              "Enter your phone number to continue",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Input Field (Transparent/White)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withValues(alpha: 0.9), // Increased opacity
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isFocused
                                  ? AppTheme.primaryGreen
                                  : Colors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            keyboardType: TextInputType.phone,
                            autofillHints: const [
                              AutofillHints.telephoneNumber
                            ],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Colors.black, // Changed to black
                            ),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)
                                      ?.translate('phone_number_hint') ??
                                  "Phone Number",
                              hintStyle: const TextStyle(
                                letterSpacing: 0,
                                fontWeight: FontWeight.w400,
                                color: Colors
                                    .black54, // Better contrast on nearly white bg
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 20, right: 12),
                                child: Text(
                                  "🇮🇳 +91",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black, // Changed to black
                                  ),
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                  minWidth: 0, minHeight: 0),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 22),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        if (_isVerifying)
                          const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white))
                        else
                          ElevatedButton(
                            onPressed: _handlePhoneVerification,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  Colors.black, // Dark text on white button
                              minimumSize: const Size(double.infinity, 64),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                            child: Text(
                              AppLocalizations.of(context)
                                      ?.translate('continue') ??
                                  "Continue",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),

                        const SizedBox(height: 24),

                        TextButton(
                          onPressed: () {
                            Provider.of<AuthProvider>(context, listen: false)
                                .loginAsGuest();
                          },
                          child: Text(
                            "Continue as Guest",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        Text(
                          AppLocalizations.of(context)
                                  ?.translate('privacy_note') ??
                              "Your privacy is our priority. We'll send a secure OTP.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
