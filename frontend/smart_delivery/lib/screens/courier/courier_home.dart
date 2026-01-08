import 'package:flutter/material.dart';
import 'package:smart_delivery/screens/courier/available_requests_screen.dart';
import 'package:smart_delivery/screens/courier/my_deliveries_screen.dart';
import 'package:smart_delivery/screens/courier/profile.dart';
import 'package:smart_delivery/screens/courier/morescreen.dart';

class CourierHomeScreen extends StatefulWidget {
  const CourierHomeScreen({super.key});

  @override
  State<CourierHomeScreen> createState() => _CourierHomeScreenState();
}

class _CourierHomeScreenState extends State<CourierHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      body: Column(
        children: [
          /// HEADER (NE CHANGE PAS)
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF6A1B6D),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Spacer(),
                        Text(
                          'Home',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.notifications_none, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text('HI',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    const Text(
                      'Hi Ahmed , Wish You A Happy Day',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// CONTENU QUI CHANGE
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildContent(),
            ),
          ),
        ],
      ),

      /// BOTTOM NAVIGATION (FIXÉ)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF6A1B6D),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.airport_shuttle),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
            
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'More',
          ),
        ],
      ),
    );
  }

  /// 🔁 CONTENU SELON L’ICÔNE
  Widget _buildContent() {
    switch (_currentIndex) {
      case 0:
        return AvailableRequestsScreen();
      case 1:
        return MyDeliveriesScreen();
      case 2:
        return ProfileScreen();
      case 3:
        return MoreScreen();
      default:
        return AvailableRequestsScreen();
    }
  }


}
