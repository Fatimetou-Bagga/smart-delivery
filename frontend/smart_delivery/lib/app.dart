import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_delivery/providers/auth_provider.dart';
import 'package:smart_delivery/providers/delivery_request_provider.dart';
import 'package:smart_delivery/screens/auth/auth_gate.dart';

class SmartDeliveryApp extends StatelessWidget {
  const SmartDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) {
            final auth = AuthProvider();
            auth.restoreSession(); // 🔑 OK ici
            return auth;
          },
        ),

        ChangeNotifierProvider<DeliveryRequestProvider>(
          create: (_) => DeliveryRequestProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Delivery',
        theme: ThemeData(primarySwatch: Colors.green),
        home: const AuthGate(),
      ),
    );
  }
}
