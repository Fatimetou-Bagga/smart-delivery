import 'package:flutter/material.dart';
import '../../services/delivery_request_service.dart';

class CreateDeliveryRequestScreen extends StatefulWidget {
  const CreateDeliveryRequestScreen({super.key});

  @override
  State<CreateDeliveryRequestScreen> createState() =>
      _CreateDeliveryRequestScreenState();
}

class _CreateDeliveryRequestScreenState
    extends State<CreateDeliveryRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = DeliveryRequestService();

  final _productType = TextEditingController();
  final _description = TextEditingController();
  final _weight = TextEditingController();
  final _pickup = TextEditingController();
  final _delivery = TextEditingController();

  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _service.createDeliveryRequest(
        productType: _productType.text,
        description: _description.text,
        weight: double.parse(_weight.text),
        pickupAddress: _pickup.text,
        deliveryAddress: _delivery.text,
      );

      if (!mounted) return;
      Navigator.pop(context); // retour dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la création')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle demande')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _productType,
                decoration: const InputDecoration(labelText: 'Type de produit'),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _weight,
                decoration: const InputDecoration(labelText: 'Poids'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _pickup,
                decoration: const InputDecoration(
                  labelText: 'Adresse de départ',
                ),
              ),
              TextFormField(
                controller: _delivery,
                decoration: const InputDecoration(
                  labelText: 'Adresse de destination',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Envoyer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
