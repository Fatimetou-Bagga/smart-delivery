import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/delivery_service.dart';
import '../../../models/delivery_request.dart';
import '../../auth/pages/login_page.dart';
import 'create_request_page.dart';
import 'request_details_page.dart';

class ClientHomePage extends StatefulWidget {
  static const route = '/home/client';
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final _auth = AuthService();
  final _delivery = DeliveryService();

  bool _loading = true;
  List<DeliveryRequest> _all = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final list = await _delivery.myRequests();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!mounted) return;
      setState(() {
        _all = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  DeliveryRequest? get _current {
    for (final r in _all) {
      if (r.isActive) return r;
    }
    return null;
  }

  List<DeliveryRequest> get _history => _all.where((r) => r.isFinished).toList();

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, LoginPage.route, (_) => false);
  }

  Color _statusColor(String s) {
    final st = s.toUpperCase();
    if (st == 'PENDING') return Colors.orange;
    if (st == 'ACCEPTED' || st == 'ASSIGNED') return Colors.blue;
    if (st == 'IN_PROGRESS') return Colors.indigo;
    if (st == 'DELIVERED') return Colors.green;
    return Colors.grey;
  }

  IconData _statusIcon(String s) {
    final st = s.toUpperCase();
    if (st == 'PENDING') return Icons.hourglass_top_rounded;
    if (st == 'ACCEPTED' || st == 'ASSIGNED') return Icons.assignment_turned_in_outlined;
    if (st == 'IN_PROGRESS') return Icons.directions_bike_rounded;
    if (st == 'DELIVERED') return Icons.check_circle_outline_rounded;
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Delivery'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: current != null
            ? () => _toast('You already have an active delivery.')
            : () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateRequestPage()),
                );
                if (created == true) _load();
              },
        label: const Text('New Order'),
        icon: const Icon(Icons.add),
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
                    icon: Icons.local_shipping_outlined,
                    subtitle: 'Track your active order in real time',
                  ),
                  const SizedBox(height: 10),

                  if (current == null)
                    const _EmptyCard(
                      icon: Icons.info_outline,
                      title: 'No active delivery',
                      subtitle: 'Create a new order to start.',
                    )
                  else
                    _RequestCard(
                      r: current,
                      statusColor: _statusColor(current.status),
                      statusIcon: _statusIcon(current.status),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RequestDetailsPage(request: current)),
                        );
                        _load(silent: true);
                      },
                    ),

                  const SizedBox(height: 18),
                  _SectionHeader(
                    title: 'History',
                    icon: Icons.history_rounded,
                    subtitle: 'Delivered orders',
                  ),
                  const SizedBox(height: 10),

                  if (_history.isEmpty)
                    const _EmptyCard(
                      icon: Icons.history_toggle_off,
                      title: 'No history yet',
                      subtitle: 'Your delivered orders will appear here.',
                    )
                  else
                    ..._history.map(
                      (r) => _RequestCard(
                        r: r,
                        statusColor: _statusColor(r.status),
                        statusIcon: _statusIcon(r.status),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RequestDetailsPage(request: r)),
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

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

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

class _RequestCard extends StatelessWidget {
  final DeliveryRequest r;
  final VoidCallback onTap;
  final Color statusColor;
  final IconData statusIcon;

  const _RequestCard({
    required this.r,
    required this.onTap,
    required this.statusColor,
    required this.statusIcon,
  });

  @override
  Widget build(BuildContext context) {
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
                      'Order #${r.id}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                  _StatusChip(text: r.status, color: statusColor),
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
                  const Icon(Icons.chevron_right),
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
