import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/storage/app_prefs.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../home/pages/client_home_page.dart';
import '../../home/pages/courier_home_page.dart';
import 'register_page.dart';
import 'server_settings_page.dart';

enum UserType { client, courier }

class LoginPage extends StatefulWidget {
  static const route = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();

  UserType _type = UserType.client;

  final _serverCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _loadBaseUrl();
  }

  Future<void> _loadBaseUrl() async {
    final base = await AppPrefs.getBaseUrl();
    if (!mounted) return;
    setState(() => _serverCtrl.text = base);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _invalidMsg() => 'Invalid username or password.';

  Future<void> _login() async {
    setState(() => _loading = true);

    try {
      await _auth.setServerBaseUrlFromInput(_serverCtrl.text);

      final expectedRole =
          (_type == UserType.client) ? AppLoginRole.client : AppLoginRole.courier;

      final me = await _auth.loginAndEnforceRole(
        username: _userCtrl.text,
        password: _passCtrl.text,
        expectedRole: expectedRole,
      );

      if (!mounted) return;

      // If null => wrong password OR role mismatch OR any auth error
      if (me == null) {
        _toast(_invalidMsg());
        return;
      }

      // Role matched, safe to route
      if (me.role.toUpperCase() == 'COURIER') {
        Navigator.pushReplacementNamed(context, CourierHomePage.route);
      } else {
        Navigator.pushReplacementNamed(context, ClientHomePage.route);
      }
    } catch (_) {
      // Never leak details
      _toast(_invalidMsg());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showRegister = _type == UserType.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Delivery'),
        actions: [
          IconButton(
            tooltip: 'Server settings',
            onPressed: () => Navigator.pushNamed(context, ServerSettingsPage.route),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const SizedBox(height: 10),
                const Center(child: AppLogo(size: 80)),
                const SizedBox(height: 14),
                Text(
                  'Welcome back',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 18),

                SegmentedButton<UserType>(
                  segments: const [
                    ButtonSegment(
                      value: UserType.client,
                      label: Text('Client'),
                      icon: Icon(Icons.person),
                    ),
                    ButtonSegment(
                      value: UserType.courier,
                      label: Text('Livreur'),
                      icon: Icon(Icons.delivery_dining),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (v) => setState(() => _type = v.first),
                ),
                const SizedBox(height: 14),

                AppTextField(
                  controller: _serverCtrl,
                  label: 'Server IP / Base URL',
                  hintText: '192.168.1.10:8000  OR  http://192.168.1.10:8000',
                  prefixIcon: const Icon(Icons.dns),
                ),
                const SizedBox(height: 12),

                AppTextField(
                  controller: _userCtrl,
                  label: 'Username / Email',
                  prefixIcon: const Icon(Icons.alternate_email),
                ),
                const SizedBox(height: 12),

                AppTextField(
                  controller: _passCtrl,
                  label: 'Password',
                  obscureText: _obscure,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                const SizedBox(height: 16),

                PrimaryButton(
                  text: 'Login',
                  loading: _loading,
                  onPressed: _login,
                ),

                const SizedBox(height: 10),

                if (showRegister)
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, RegisterPage.route),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text("Create a client account"),
                  ),

                const SizedBox(height: 6),
                Text(
                  showRegister
                      ? 'Couriers must be created by the admin.'
                      : 'Courier accounts are created by admin only.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
