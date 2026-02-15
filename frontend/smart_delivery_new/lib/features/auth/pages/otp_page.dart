import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import 'login_page.dart';

class OtpArgs {
  final String email;
  OtpArgs({required this.email});
}

class OtpPage extends StatefulWidget {
  static const route = '/otp';
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _auth = AuthService();
  final _codeCtrl = TextEditingController();

  bool _loading = false;
  int _secondsLeft = 60;
  Timer? _timer;

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify(String email) async {
    setState(() => _loading = true);
    try {
      await _auth.verifyOtp(email: email, code: _codeCtrl.text);

      if (!mounted) return;
      _toast("OTP verified. Please login.");
      Navigator.pushNamedAndRemoveUntil(context, LoginPage.route, (r) => false);
    } catch (e) {
      _toast(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend(String email) async {
    // Your backend.zip doesn't have resend endpoint; this will show a clean message if missing.
    try {
      await _auth.resendOtpIfAvailable(email);
      _toast("OTP resent.");
      _startTimer();
    } catch (e) {
      _toast("Resend not available on backend (missing endpoint).");
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as OtpArgs?;
    final email = args?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text(
                  'Check your email',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text('We sent a verification code to: $email'),
                const SizedBox(height: 14),

                AppTextField(
                  controller: _codeCtrl,
                  label: 'OTP Code',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.key),
                ),
                const SizedBox(height: 16),

                PrimaryButton(
                  text: 'Verify',
                  loading: _loading,
                  onPressed: email.isEmpty ? null : () => _verify(email),
                ),

                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _secondsLeft == 0 ? () => _resend(email) : null,
                  icon: const Icon(Icons.refresh),
                  label: Text(_secondsLeft == 0 ? 'Resend code' : 'Resend in $_secondsLeft s'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
