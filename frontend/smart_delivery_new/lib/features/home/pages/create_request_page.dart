import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show LatLng, Distance, LengthUnit;

import '../../../core/services/delivery_service.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class CreateRequestPage extends StatefulWidget {
  const CreateRequestPage({super.key});

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  final _delivery = DeliveryService();

  final _descCtrl = TextEditingController(text: 'Delivery request');
  final _weightCtrl = TextEditingController(text: '1.0');

  String _productType = 'OTHER';

  LatLng? _pickup;
  LatLng? _dropoff;

  bool _loading = false;

  final _map = MapController();
  LatLng _center = const LatLng(33.58990, -7.60390); // Casablanca default

  final _distance = Distance();

  String _fmtAddr(String label, LatLng p) =>
      '$label (${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)})';

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  double? get _estimatedKm {
    if (_pickup == null || _dropoff == null) return null;
    return _distance.as(LengthUnit.Kilometer, _pickup!, _dropoff!);
  }

  double? get _estimatedPriceMru {
    final km = _estimatedKm;
    if (km == null) return null;
    return km * 5; // 1 km = 5 MRU
  }

  Future<void> _setPickupCurrent() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _toast('Please enable Location (GPS) and try again.');
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.denied) {
        _toast('Location permission denied.');
        return;
      }

      if (perm == LocationPermission.deniedForever) {
        _toast('Location permission permanently denied. Enable it from settings.');
        await Geolocator.openAppSettings();
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final p = LatLng(pos.latitude, pos.longitude);

      if (!mounted) return;
      setState(() {
        _pickup = p;
        _center = p;
      });

      _map.move(p, 15);
    } catch (_) {
      _toast('Unable to get current location.');
    }
  }

  Future<bool> _confirmBeforeSubmit({
    required double km,
    required double priceMru,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Text(
          'Pickup: ${_pickup!.latitude.toStringAsFixed(5)}, ${_pickup!.longitude.toStringAsFixed(5)}\n'
          'Delivery: ${_dropoff!.latitude.toStringAsFixed(5)}, ${_dropoff!.longitude.toStringAsFixed(5)}\n\n'
          'Estimated distance: ${km.toStringAsFixed(2)} km\n'
          'Estimated price: ${priceMru.toStringAsFixed(2)} MRU (cash)\n\n'
          'Create this order?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _submit() async {
    if (_pickup == null || _dropoff == null) {
      _toast('Select pickup and delivery points on the map.');
      return;
    }

    final km = _estimatedKm;
    final price = _estimatedPriceMru;
    if (km == null || price == null) {
      _toast('Unable to calculate estimate.');
      return;
    }

    final confirmed = await _confirmBeforeSubmit(km: km, priceMru: price);
    if (!confirmed) return;

    setState(() => _loading = true);
    try {
      final weight = double.tryParse(_weightCtrl.text.trim()) ?? 1.0;

      await _delivery.createRequest(
        productType: _productType,
        description: _descCtrl.text.trim(),
        weight: weight,
        pickupAddress: _fmtAddr('Pickup', _pickup!),
        deliveryAddress: _fmtAddr('Delivery', _dropoff!),
      );

      if (!mounted) return;
      _toast('Request created.');
      Navigator.pop(context, true);
    } catch (e) {
      _toast(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      if (_pickup != null)
        Marker(
          width: 40,
          height: 40,
          point: _pickup!,
          child: const Icon(Icons.my_location, size: 36),
        ),
      if (_dropoff != null)
        Marker(
          width: 40,
          height: 40,
          point: _dropoff!,
          child: const Icon(Icons.location_on, size: 36),
        ),
    ];

    final km = _estimatedKm;
    final price = _estimatedPriceMru;

    return Scaffold(
      appBar: AppBar(title: const Text('New Order')),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 13,
                onTap: (tapPos, latlng) {
                  // NEW behavior:
                  // first tap sets pickup, next taps set delivery
                  setState(() {
                    if (_pickup == null) {
                      _pickup = latlng;
                      _center = latlng;
                    } else {
                      _dropoff = latlng;
                    }
                  });
                },
                onLongPress: (tapPos, latlng) {
                  // long press forces pickup
                  setState(() {
                    _pickup = latlng;
                    _center = latlng;
                  });
                },
              ),
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
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _setPickupCurrent,
                        icon: const Icon(Icons.gps_fixed),
                        label: const Text('Pickup: current'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() {
                          _pickup = null;
                          _dropoff = null;
                        }),
                        icon: const Icon(Icons.clear),
                        label: const Text('Reset'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (km != null && price != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.payments_outlined),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Estimated: ${km.toStringAsFixed(2)} km • ${price.toStringAsFixed(2)} MRU (cash)\nFinal price will be confirmed by the server.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                DropdownButtonFormField<String>(
                  value: _productType,
                  items: const [
                    DropdownMenuItem(value: 'DOC', child: Text('Documents')),
                    DropdownMenuItem(value: 'FOOD', child: Text('Food')),
                    DropdownMenuItem(value: 'ELEC', child: Text('Electronics')),
                    DropdownMenuItem(value: 'CLOT', child: Text('Clothes')),
                    DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => _productType = v ?? 'OTHER'),
                  decoration: const InputDecoration(labelText: 'Product type'),
                ),
                const SizedBox(height: 10),

                AppTextField(
                  controller: _descCtrl,
                  label: 'Description',
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                const SizedBox(height: 10),

                AppTextField(
                  controller: _weightCtrl,
                  label: 'Weight (kg)',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.scale_outlined),
                ),
                const SizedBox(height: 12),

                PrimaryButton(
                  text: 'Create order',
                  loading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap map: first tap sets Pickup, next tap sets Delivery.\nLong-press to set Pickup manually.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
