import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _password2 = TextEditingController();
  final _phone = TextEditingController();

  bool _loading = false;

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await context.read<AuthProvider>().registerClient(
        username: _username.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
        password2: _password2.text.trim(),
        phoneNumber: _phone.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Compte créé avec succès')));

      Navigator.pop(context); // retour login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l’inscription')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(
                  labelText: 'Nom d’utilisateur',
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (v) =>
                    v!.length < 6 ? 'Au moins 6 caractères' : null,
              ),
              TextFormField(
                controller: _password2,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                ),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Champ requis';
                  if (v != _password.text)
                    return 'Les mots de passe ne correspondent pas';
                  return null;
                },
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : () => _submit(context),
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Créer un compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
