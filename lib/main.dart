import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:medinest/core/localization/app_localizations.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:medinest/state/language_provider.dart';
import 'package:medinest/state/auth_provider.dart';
import 'package:medinest/state/booking_provider.dart';
import 'package:medinest/state/doctor_provider.dart';
import 'package:medinest/state/product_provider.dart';
import 'package:medinest/state/cart_provider.dart';
import 'package:medinest/state/diet_provider.dart';
import 'package:medinest/presentation/home/home_screen.dart';
import 'package:medinest/presentation/core/no_internet_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://uxxttraidwajbopdykca.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV4eHR0cmFpZHdhamJvcGR5a2NhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYzMjkyMDMsImV4cCI6MjA4MTkwNTIwM30.JdSPrw6l9keo8xgk5_BWGIZTt-boSknwXq87sVYUFEA',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => DietProvider()),
      ],
      child: const MediNestApp(),
    ),
  );
}

class MediNestApp extends StatelessWidget {
  const MediNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'MediNest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: languageProvider.appLocale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
        Locale('mr', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const ConnectivityWrapper(child: HomeScreen()),
    );
  }
}

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      stream: Connectivity().onConnectivityChanged.map((results) =>
          results.isNotEmpty ? results.first : ConnectivityResult.none),
      builder: (context, snapshot) {
        final connectivityResult = snapshot.data;
        if (connectivityResult == ConnectivityResult.none) {
          return const NoInternetScreen();
        }
        return child;
      },
    );
  }
}
