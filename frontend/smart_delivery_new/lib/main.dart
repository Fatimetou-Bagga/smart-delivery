import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/pages/startup_page.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/register_page.dart';
import 'features/auth/pages/otp_page.dart';
import 'features/auth/pages/server_settings_page.dart';

import 'features/home/pages/client_home_page.dart';
import 'features/home/pages/courier_home_page.dart';

void main() {
  runApp(const SmartDeliveryApp());
}

class SmartDeliveryApp extends StatelessWidget {
  const SmartDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Delivery',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      routes: {
        StartupPage.route: (_) => const StartupPage(),
        LoginPage.route: (_) => const LoginPage(),
        RegisterPage.route: (_) => const RegisterPage(),
        OtpPage.route: (_) => const OtpPage(),
        ServerSettingsPage.route: (_) => const ServerSettingsPage(),
        ClientHomePage.route: (_) => const ClientHomePage(),
        CourierHomePage.route: (_) => const CourierHomePage(),
      },
      initialRoute: StartupPage.route,
    );
  }
}
