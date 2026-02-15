import 'package:flutter/material.dart';
import '../../../models/delivery.dart';

class CourierDeliveryDetailsPage extends StatelessWidget {
  final Delivery delivery;
  const CourierDeliveryDetailsPage({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final r = delivery.deliveryRequest;
    final price = r.priceMru;

    return Scaffold(
      appBar: AppBar(title: Text('Delivery #${delivery.id}')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.delivery_dining),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Status: ${delivery.status}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _Line(icon: Icons.my_location, title: 'Pickup', value: r.pickupAddress),
                  const SizedBox(height: 10),
                  _Line(icon: Icons.place_outlined, title: 'Delivery', value: r.deliveryAddress),
                  const SizedBox(height: 10),
                  _Line(icon: Icons.payments_outlined, title: 'Price', value: price != null ? '${price.toStringAsFixed(2)} MRU (cash)' : '—'),
                  const SizedBox(height: 10),
                  _Line(icon: Icons.description_outlined, title: 'Description', value: r.description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _Line({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}
