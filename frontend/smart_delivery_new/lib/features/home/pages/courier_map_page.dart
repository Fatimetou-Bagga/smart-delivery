import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/delivery_service.dart';
import '../../../models/delivery.dart';

class CourierMapPage extends StatefulWidget {
  final Delivery delivery;
  const CourierMapPage({super.key, required this.delivery});

  @override
  State<CourierMapPage> createState() => _CourierMapPageState();
}

class _CourierMapPageState extends State<CourierMapPage> {
  final _deliveryService = DeliveryService();
  Timer? _pushTimer;

  LatLng? _courierPos;
  late LatLng _center;

  LatLng? _parse(String s) {
    final m = RegExp(r'\(([-\d.]+)\s*,\s*([-\d.]+)\)').firstMatch(s);
    if (m == null) return null;
    final lat = double.tryParse(m.group(1) ?? '');
    final lng = double.tryParse(m.group(2) ?? '');
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  void initState() {
    super.initState();
    _center = _parse(widget.delivery.deliveryRequest.pickupAddress) ?? const LatLng(33.58990, -7.60390);
    _startPushing();
  }

  @override
  void dispose() {
    _pushTimer?.cancel();
    super.dispose();
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _toast('Please enable GPS.');
      return false;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      _toast('Location permission denied.');
      return false;
    }
    if (perm == LocationPermission.deniedForever) {
      _toast('Permission denied forever. Enable it from settings.');
      await Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  Future<void> _startPushing() async {
    if (!await _ensureLocationPermission()) return;

    _pushTimer?.cancel();
    _pushTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        final p = LatLng(pos.latitude, pos.longitude);

        if (!mounted) return;
        setState(() => _courierPos = p);

        await _deliveryService.pushCourierLocation(p.latitude, p.longitude);
      } catch (_) {
        // keep quiet to avoid spamming
      }
    });
  }

  Future<void> _setStatus(String status) async {
    try {
      await _deliveryService.updateDeliveryStatus(widget.delivery.id, status);
      _toast('Status updated: $status');
      if (status == 'DELIVERED') {
        _pushTimer?.cancel();
        if (!mounted) return;
        Navigator.pop(context);
      }
    } catch (e) {
      _toast(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickup = _parse(widget.delivery.deliveryRequest.pickupAddress);
    final dropoff = _parse(widget.delivery.deliveryRequest.deliveryAddress);

    final markers = <Marker>[
      if (pickup != null)
        Marker(width: 44, height: 44, point: pickup, child: const Icon(Icons.my_location, size: 38)),
      if (dropoff != null)
        Marker(width: 44, height: 44, point: dropoff, child: const Icon(Icons.location_on, size: 38)),
      if (_courierPos != null)
        Marker(width: 54, height: 54, point: _courierPos!, child: const Icon(Icons.delivery_dining, size: 44)),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Delivery #${widget.delivery.id}')),
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _setStatus('IN_PROGRESS'),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _setStatus('DELIVERED'),
                    icon: const Icon(Icons.check),
                    label: const Text('Finish'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
