import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/storage/app_prefs.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class ServerSettingsPage extends StatefulWidget {
  static const route = '/settings/server';
  const ServerSettingsPage({super.key});

  @override
  State<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends State<ServerSettingsPage> {
  final _auth = AuthService();
  final _serverCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _serverCtrl.text = await AppPrefs.getBaseUrl();
    setState(() {});
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _auth.setServerBaseUrlFromInput(_serverCtrl.text);
      _toast("Server saved.");
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _toast(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Server Settings')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                AppTextField(
                  controller: _serverCtrl,
                  label: 'Base URL',
                  hintText: 'http://192.168.1.10:8000',
                  prefixIcon: const Icon(Icons.dns),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'Save',
                  loading: _saving,
                  onPressed: _save,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tip: You can enter "192.168.1.10:8000" and it will be converted to http:// automatically.',
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
