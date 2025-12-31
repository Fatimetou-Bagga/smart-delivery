import 'package:flutter/material.dart';
import '../../services/delivery_service.dart';

class MyDeliveriesScreen extends StatelessWidget {
  const MyDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = DeliveryService();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes livraisons')),
      body: FutureBuilder<List<dynamic>>(
        future: service.getMyDeliveries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erreur'));
          }

          final deliveries = snapshot.data!;

          if (deliveries.isEmpty) {
            return const Center(child: Text('Aucune livraison'));
          }

          return ListView.builder(
            itemCount: deliveries.length,
            itemBuilder: (_, index) {
              final d = deliveries[index];
              return ListTile(
                title: Text('Livraison #${d['id']}'),
                subtitle: Text('Statut: ${d['status']}'),
              );
            },
          );
        },
      ),
    );
  }
}
