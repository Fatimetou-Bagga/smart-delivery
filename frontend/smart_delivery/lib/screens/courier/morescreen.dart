import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// ================= HEADER =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    /// Avatar
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E3A8A),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// Name
                    const Text(
                      'Ahmed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// ================= MENU ITEMS =================
              _MenuItem(icon: Icons.home, title: 'Home'),
              _MenuItem(icon: Icons.info_outline, title: 'About Chauffeur'),
              _MenuItem(icon: Icons.description_outlined, title: 'Terms And Conditions'),
              _MenuItem(icon: Icons.email_outlined, title: 'Contact us'),
              _MenuItem(icon: Icons.feedback_outlined, title: 'Complaints & Suggestions'),
              _MenuItem(icon: Icons.star_border, title: 'Rate App'),
              _MenuItem(icon: Icons.share_outlined, title: 'Share App'),
              _MenuItem(icon: Icons.help_outline, title: 'Faq'),
              _MenuItem(icon: Icons.settings_outlined, title: 'Setting'),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= MENU ITEM WIDGET =================
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _MenuItem({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: const Color(0xFF6A1B6D),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigation ici plus tard
          },
        ),
        const Divider(height: 1),
      ],
    );
  }
}
