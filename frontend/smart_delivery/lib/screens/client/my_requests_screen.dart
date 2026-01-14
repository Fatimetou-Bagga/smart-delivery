import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_delivery/providers/delivery_request_provider.dart';
import '../../providers/delivery_provider.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DeliveryRequestProvider>().fetchMyRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeliveryRequestProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Mes demandes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 20),

              if (provider.loading) const CircularProgressIndicator(),

              if (!provider.loading && provider.requests.isEmpty)
                const Text('Aucune demande'),

              if (!provider.loading)
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.requests.length,
                    itemBuilder: (context, index) {
                      final r = provider.requests[index];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            '${r.pickupAddress} → ${r.deliveryAddress}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text('Statut : ${r.status}'),
                          trailing: r.status == 'PENDING'
                              ? TextButton(
                                  onPressed: () {
                                    provider.cancel(r.id);
                                  },
                                  child: const Text(
                                    'Annuler',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
