import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/delivery_request_provider.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _pickupCtrl = TextEditingController();
  final _deliveryCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String _productType = 'DOC';

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _deliveryCtrl.dispose();
    _descriptionCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeliveryRequestProvider>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Nouvelle commande"),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CupertinoSegmentedControl<String>(
              children: const {
                'DOC': Text('Documents'),
                'FOOD': Text('Nourriture'),
                'ELEC': Text('Électronique'),
                'CLOT': Text('Vêtements'),
                'OTHER': Text('Autre'),
              },
              groupValue: _productType,
              onValueChanged: (value) {
                setState(() {
                  _productType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              placeholder: "Adresse de départ",
              controller: _pickupCtrl,
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              placeholder: "Adresse de livraison",
              controller: _deliveryCtrl,
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              placeholder: "Description",
              controller: _descriptionCtrl,
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              placeholder: "Poids (kg)",
              keyboardType: TextInputType.number,
              controller: _weightCtrl,
            ),
            const SizedBox(height: 24),
            CupertinoButton.filled(
              child: provider.isLoading
                  ? const CupertinoActivityIndicator()
                  : const Text("Créer la commande"),
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      if (_pickupCtrl.text.isEmpty ||
                          _deliveryCtrl.text.isEmpty ||
                          _descriptionCtrl.text.isEmpty ||
                          _weightCtrl.text.isEmpty) {
                        showCupertinoDialog(
                          context: context,
                          builder: (_) => CupertinoAlertDialog(
                            title: const Text("Erreur"),
                            content: const Text("Tous les champs sont requis"),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text("OK"),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      try {
                        await provider.createRequest(
                          productType: _productType,
                          description: _descriptionCtrl.text,
                          weight: double.parse(_weightCtrl.text),
                          pickupAddress: _pickupCtrl.text,
                          deliveryAddress: _deliveryCtrl.text,
                        );

                        showCupertinoDialog(
                          context: context,
                          builder: (_) => CupertinoAlertDialog(
                            title: const Text("Succès"),
                            content: const Text("Commande créée !"),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text("OK"),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        showCupertinoDialog(
                          context: context,
                          builder: (_) => CupertinoAlertDialog(
                            title: const Text("Erreur"),
                            content: Text(e.toString()),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text("OK"),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
