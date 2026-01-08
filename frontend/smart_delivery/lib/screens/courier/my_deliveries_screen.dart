import 'package:flutter/material.dart';
import '../../services/delivery_service.dart';

class MyDeliveriesScreen extends StatefulWidget {
  const MyDeliveriesScreen({super.key});

  @override
  State<MyDeliveriesScreen> createState() => _MyDeliveriesScreenState();
}

class _MyDeliveriesScreenState extends State<MyDeliveriesScreen> {
  final DeliveryService _service = DeliveryService();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMyDeliveries();
  }

  void _refresh() {
    setState(() {
      _future = _service.getMyDeliveries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes livraisons')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
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
            itemBuilder: (context, index) {
              final d = deliveries[index];
              final status = d['status'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('Livraison #${d['id']}'),
                  subtitle: Text('Statut: $status'),
                  trailing: SizedBox(
                    width: 120,
                    child: _buildActionButton(d),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> delivery) {
    final status = delivery['status'].toString().toUpperCase();

    if (status == 'ASSIGNED') {
      return ElevatedButton(
        onPressed: () async {
          await _service.updateDeliveryStatus(delivery['id'], 'IN_PROGRESS');
          _refresh();
        },
        child: const Text('Démarrer'),
      );
    }

    if (status == 'IN_PROGRESS') {
      return ElevatedButton(
        onPressed: () async {
          await _service.updateDeliveryStatus(delivery['id'], 'DELIVERED');
          _refresh();
        },
        child: const Text('Livrer'),
      );
    }

    if (status == 'DELIVERED') {
      return const Icon(Icons.check_circle, color: Colors.green);
    }

    return const SizedBox.shrink();
  }
}
