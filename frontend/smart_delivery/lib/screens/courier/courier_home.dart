import 'package:flutter/material.dart';
import 'available_requests_screen.dart';
import 'my_deliveries_screen.dart';

class CourierHomeScreen extends StatelessWidget {
  const CourierHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Espace Livreur')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AvailableRequestsScreen(),
                  ),
                );
              },
              child: const Text('Demandes disponibles'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyDeliveriesScreen()),
                );
              },
              child: const Text('Mes livraisons'),
            ),
          ],
        ),
      ),
    );
  }
}
