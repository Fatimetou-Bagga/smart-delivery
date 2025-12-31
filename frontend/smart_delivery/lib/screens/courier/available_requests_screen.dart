import 'package:flutter/material.dart';
import '../../services/delivery_service.dart';

class AvailableRequestsScreen extends StatefulWidget {
  const AvailableRequestsScreen({super.key});

  @override
  State<AvailableRequestsScreen> createState() =>
      _AvailableRequestsScreenState();
}

class _AvailableRequestsScreenState extends State<AvailableRequestsScreen> {
  final DeliveryService _service = DeliveryService();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getAvailableRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demandes disponibles')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erreur'));
          }

          final requests = snapshot.data!;

          if (requests.isEmpty) {
            return const Center(child: Text('Aucune demande'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (_, index) {
              final r = requests[index];
              return Card(
                child: ListTile(
                  title: Text(
                    '${r['pickup_address']} → ${r['delivery_address']}',
                  ),
                  subtitle: Text('Type: ${r['product_type']}'),
                  trailing: ElevatedButton(
                    child: const Text('Accepter'),
                    onPressed: () async {
                      await _service.acceptRequest(r['id']);
                      if (!mounted) return;
                      setState(() {
                        _future = _service.getAvailableRequests();
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
