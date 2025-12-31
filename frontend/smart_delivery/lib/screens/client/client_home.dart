import 'package:flutter/material.dart';
import 'package:smart_delivery/screens/client/create_request_screen.dart';
import 'create_request_screen.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client Dashboard')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Créer une demande de livraison'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateDeliveryRequestScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
