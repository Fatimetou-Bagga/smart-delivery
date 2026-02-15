import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/delivery_service.dart';
import '../../../models/delivery.dart';
import '../../auth/pages/login_page.dart';
import 'courier_map_page.dart';
import 'courier_delivery_details_page.dart';

class CourierHomePage extends StatefulWidget {
  static const route = '/home/courier';
  const CourierHomePage({super.key});

  @override
  State<CourierHomePage> createState() => _CourierHomePageState();
}

class _CourierHomePageState extends State<CourierHomePage> {
  final _auth = AuthService();
  final _delivery = DeliveryService();

  bool _loading = true;
  Delivery? _currentDelivery;
  List<Delivery> _history = [];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final deliveries = await _delivery.myDeliveries();

      final active = deliveries.where((d) => d.status != 'DELIVERED').toList();
      final hist = deliveries.where((d) => d.status == 'DELIVERED').toList();

      active.sort((a, b) => b.id.compareTo(a.id));
      hist.sort((a, b) => b.id.compareTo(a.id));

      if (!mounted) return;
      setState(() {
        _currentDelivery = active.isNotEmpty ? active.first : null;
        _history = hist;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _toast('Failed to load deliveries: ${e.toString()}');
    }
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, LoginPage.route, (_) => false);
  }

  Color _statusColor(String s) {
    final st = s.toUpperCase();
    if (st == 'ASSIGNED' || st == 'ACCEPTED') return Colors.blue;
    if (st == 'IN_PROGRESS') return Colors.indigo;
    if (st == 'DELIVERED') return Colors.green;
    return Colors.grey;
  }

  IconData _statusIcon(String s) {
    final st = s.toUpperCase();
    if (st == 'ASSIGNED' || st == 'ACCEPTED') return Icons.assignment_turned_in_outlined;
    if (st == 'IN_PROGRESS') return Icons.directions_bike_rounded;
    if (st == 'DELIVERED') return Icons.check_circle_outline_rounded;
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final cur = _currentDelivery;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livreur'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
                children: [
                  _SectionHeader(
                    title: 'Current Delivery',
                    icon: Icons.delivery_dining,
                    subtitle: 'Assigned to you by admin',
                  ),
                  const SizedBox(height: 10),

                  if (cur == null)
                    const _EmptyCard(
                      icon: Icons.info_outline,
                      title: 'No active delivery',
                      subtitle: 'Wait for admin assignment.',
                    )
                  else
                    _DeliveryCard(
                      delivery: cur,
                      statusColor: _statusColor(cur.status),
                      statusIcon: _statusIcon(cur.status),
                      trailingIcon: Icons.map,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CourierMapPage(delivery: cur)),
                      ),
                    ),

                  const SizedBox(height: 18),
                  _SectionHeader(
                    title: 'History',
                    icon: Icons.history_rounded,
                    subtitle: 'Completed deliveries',
                  ),
                  const SizedBox(height: 10),

                  if (_history.isEmpty)
                    const _EmptyCard(
                      icon: Icons.history_toggle_off,
                      title: 'No completed deliveries yet',
                      subtitle: 'Your delivered trips will appear here.',
                    )
                  else
                    ..._history.map(
                      (d) => _DeliveryCard(
                        delivery: d,
                        statusColor: _statusColor(d.status),
                        statusIcon: _statusIcon(d.status),
                        trailingIcon: Icons.chevron_right,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CourierDeliveryDetailsPage(delivery: d)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final Delivery delivery;
  final VoidCallback onTap;
  final Color statusColor;
  final IconData statusIcon;
  final IconData trailingIcon;

  const _DeliveryCard({
    required this.delivery,
    required this.onTap,
    required this.statusColor,
    required this.statusIcon,
    required this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final r = delivery.deliveryRequest;
    final price = r.priceMru;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Delivery #${delivery.id}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                  _StatusChip(text: delivery.status, color: statusColor),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.my_location, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(r.pickupAddress, maxLines: 2, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(r.deliveryAddress, maxLines: 2, overflow: TextOverflow.ellipsis)),
                ],
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      price != null ? 'Price: ${price.toStringAsFixed(2)} MRU (cash)' : 'Price: —',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Icon(trailingIcon),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}
