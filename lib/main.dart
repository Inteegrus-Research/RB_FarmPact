import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmpact/themes/theme.dart';
import 'package:farmpact/providers/farmer_provider.dart';
import 'package:farmpact/providers/location_provider.dart';
import 'package:farmpact/providers/notification_provider.dart';
import 'package:farmpact/providers/livestock_provider.dart';
import 'package:farmpact/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Starting FarmPact app...');

  runApp(const FarmPactApp());
}

class FarmPactApp extends StatelessWidget {
  const FarmPactApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FarmerProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LivestockProvider()),
      ],
      child: MaterialApp(
        title: 'FarmPact - Advanced Farmer Assistant',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
