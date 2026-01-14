import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// TITLE
              const Text(
                'Profil Client',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 30),

              /// CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    /// ICON
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(45),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.green,
                        size: 45,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// USERNAME
                    Text(
                      auth.user?.username ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// ROLE
                    const Text(
                      'Client',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// EDIT PROFILE (optionnel pour plus tard)
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.green),
                title: const Text('Modifier le profil'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Plus tard
                },
              ),

              const Divider(),

              /// LOGOUT
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
