import 'package:flutter/material.dart';

class SmartDeliveryApp extends StatelessWidget {
  const SmartDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const Scaffold(
        body: Center(
          child: Text('Smart Delivery', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
