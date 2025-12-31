import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_delivery/screens/client/client_home.dart';
import 'package:smart_delivery/screens/courier/courier_home.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    if (auth.role == 'CLIENT') {
      return const ClientHomeScreen();
    }

    if (auth.role == 'COURIER') {
      return const CourierHomeScreen();
    }

    return const LoginScreen();
  }
}
