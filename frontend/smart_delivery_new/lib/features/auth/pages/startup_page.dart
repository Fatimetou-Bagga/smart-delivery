import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/storage/app_prefs.dart';
import '../../home/pages/client_home_page.dart';
import '../../home/pages/courier_home_page.dart';
import 'login_page.dart';

class StartupPage extends StatefulWidget {
  static const route = '/';
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      final token = await AppPrefs.getAccessToken();
      if (token == null) {
        _goLogin();
        return;
      }

      // Validate token + get role
      final me = await _auth.me();

      if (!mounted) return;

      if (me.role.toUpperCase() == 'COURIER') {
        Navigator.pushReplacementNamed(context, CourierHomePage.route);
      } else {
        // treat ADMIN as client or change if you want a separate admin page
        Navigator.pushReplacementNamed(context, ClientHomePage.route);
      }
    } catch (_) {
      // Token invalid / server changed / etc.
      await AppPrefs.clearTokens();
      if (!mounted) return;
      _goLogin();
    }
  }

  void _goLogin() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, LoginPage.route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
