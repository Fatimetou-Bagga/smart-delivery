import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_delivery/providers/auth_provider.dart';
import 'package:smart_delivery/screens/auth/auth_gate.dart';
import 'package:smart_delivery/screens/auth/login_screen.dart';

class SmartDeliveryApp extends StatelessWidget {
  const SmartDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final auth = AuthProvider();
        auth.restoreSession(); // 🔑 ICI
        return auth;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Delivery',
        theme: ThemeData(primarySwatch: Colors.green),
        home: const AuthGate(),
      ),
    );
  }
}
