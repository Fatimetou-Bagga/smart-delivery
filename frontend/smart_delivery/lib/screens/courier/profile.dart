import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      body: SafeArea(
        child: SingleChildScrollView( // ✅ FIX OVERFLOW
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// TITLE
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
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
                          color: const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(45),
                        ),
                        child: const Icon(
                          Icons.local_shipping,
                          color: Color(0xFF6A1B6D),
                          size: 45,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// ROLE
                      const Text(
                        'Chauffeur',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6A1B6D),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// EDIT PROFILE
                _ProfileItem(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {},
                ),

                const Divider(),

                /// LOGOUT
                _ProfileItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =======================
/// PROFILE ITEM
/// =======================
class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;

  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = const Color(0xFF6A1B6D),
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
