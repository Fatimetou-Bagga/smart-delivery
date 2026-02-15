import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/delivery_service.dart';
import '../../../models/delivery_request.dart';
import '../../../models/tracking_latest.dart';

class RequestDetailsPage extends StatefulWidget {
  final DeliveryRequest request;
  const RequestDetailsPage({super.key, required this.request});

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  final _delivery = DeliveryService();

  late DeliveryRequest _req; // keep local state (not widget.request)

  TrackingLatest? _latest;
  String? _info;
  Timer? _timer;

  LatLng _center = const LatLng(33.58990, -7.60390);

  @override
  void initState() {
    super.initState();
    _req = widget.request;
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
    _poll();
    _refreshReq();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  LatLng? _parse(String s) {
    final m = RegExp(r'\(([-\d.]+)\s*,\s*([-\d.]+)\)').firstMatch(s);
    if (m == null) return null;
    final lat = double.tryParse(m.group(1) ?? '');
    final lng = double.tryParse(m.group(2) ?? '');
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  Future<void> _refreshReq() async {
    try {
      final updated = await _delivery.getRequest(_req.id);
      if (!mounted) return;
      setState(() => _req = updated);
    } catch (_) {}
  }

  Future<void> _poll() async {
    if (!_req.isActive) return;

    try {
      final latest = await _delivery.trackingLatest(_req.id);
      if (!mounted) return;
      setState(() {
        _latest = latest;
        _info = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _latest = null;
        _info = 'Waiting for driver assignment / tracking...';
      });
    }
  }

  Future<void> _confirmReceived() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delivery'),
        content: const Text('Did you receive your order? This will finish the delivery.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _delivery.confirmReceived(_req.id);
      await _refreshReq();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery confirmed.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickup = _parse(_req.pickupAddress);
    final dropoff = _parse(_req.deliveryAddress);
    if (pickup != null) _center = pickup;

    final markers = <Marker>[
      if (pickup != null)
        Marker(width: 44, height: 44, point: pickup, child: const Icon(Icons.my_location, size: 38)),
      if (dropoff != null)
        Marker(width: 44, height: 44, point: dropoff, child: const Icon(Icons.location_on, size: 38)),
      if (_latest != null)
        Marker(
          width: 54,
          height: 54,
          point: LatLng(_latest!.lat, _latest!.lng),
          child: const Icon(Icons.delivery_dining, size: 44),
        ),
    ];

    final price = _req.priceMru;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${_req.id}'),
        actions: [
          IconButton(onPressed: _refreshReq, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(initialCenter: _center, initialZoom: 13),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'smart_delivery_new',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${_req.status}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('From: ${_req.pickupAddress}'),
                  Text('To: ${_req.deliveryAddress}'),
                  if (price != null) ...[
                    const SizedBox(height: 6),
                    Text('Price: ${price.toStringAsFixed(2)} MRU (cash)'),
                  ],
                  const SizedBox(height: 8),
                  if (_info != null) Text(_info!),
                  if (_latest != null)
                    Text('Driver updated: ${_latest!.updatedAt} (every 2s)'),
                  const SizedBox(height: 8),
                  const Text('Payment: Cash', style: TextStyle(fontWeight: FontWeight.w600)),

                  if (_req.status == 'ACCEPTED' || _req.status == 'IN_PROGRESS') ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _confirmReceived,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Confirm received'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
