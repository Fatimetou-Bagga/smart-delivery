import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/delivery_provider.dart';

class CourierHome extends StatefulWidget {
  const CourierHome({super.key});

  @override
  State<CourierHome> createState() => _CourierHomeState();
}

class _CourierHomeState extends State<CourierHome> {
  @override
  void initState() {
    super.initState();
    // Charge les livraisons assignées au démarrage
    context.read<DeliveryProvider>().fetchDeliveries();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeliveryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes livraisons'), centerTitle: true),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.deliveries.length,
              itemBuilder: (context, index) {
                final delivery = provider.deliveries[index];

                // Détermine le prochain statut
                String nextStatus = delivery['status'] == 'ASSIGNED'
                    ? 'IN_PROGRESS'
                    : delivery['status'] == 'IN_PROGRESS'
                    ? 'DELIVERED'
                    : delivery['status'];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      "Commande #${delivery['delivery_request']['id']}",
                    ),
                    subtitle: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Produit : ${delivery['delivery_request']['product_type']}",
                          ),
                          Text("Statut : ${delivery['status']}"),
                        ],
                      ),
                    ),
                    trailing: delivery['status'] != 'DELIVERED'
                        ? SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () async {
                                await provider.updateStatus(
                                  delivery['id'],
                                  nextStatus,
                                );
                              },
                              child: Text(nextStatus),
                            ),
                          )
                        : const Icon(Icons.check, color: Colors.green),
                  ),
                );
              },
            ),
    );
  }
}
