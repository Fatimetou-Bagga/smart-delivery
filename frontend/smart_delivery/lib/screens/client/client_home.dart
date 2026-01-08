import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/delivery_request_provider.dart';
import 'create_request_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DeliveryRequestProvider>().fetchMyRequests();
    });
  }

  int countByStatus(List list, String status) {
    return list.where((e) => e.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DeliveryRequestProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Accueil Client')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateDeliveryRequestScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: p.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _StatCard('Total', p.requests.length),
                  _StatCard('Pending', countByStatus(p.requests, 'PENDING')),
                  _StatCard('Accepted', countByStatus(p.requests, 'ACCEPTED')),
                  _StatCard(
                    'Delivered',
                    countByStatus(p.requests, 'DELIVERED'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;

  const _StatCard(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(
              '$value',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
