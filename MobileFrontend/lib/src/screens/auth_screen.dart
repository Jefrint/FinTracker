import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.api, required this.onLogin});

  final ApiClient api;
  final ValueChanged<AuthSession> onLogin;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _submitting = false;
  String? _message;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _message = null;
    });

    try {
      if (_register) {
        await widget.api.register(_name.text, _email.text, _password.text);
        setState(() {
          _register = false;
          _message = 'Account created. Sign in now.';
        });
      } else {
        final session = await widget.api.login(_email.text, _password.text);
        widget.onLogin(session);
      }
    } catch (error) {
      setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('FinTracker', style: TextStyle(color: Color(0xffd8ff5f))),
                    const SizedBox(height: 8),
                    Text(
                      _register ? 'Create account' : 'Sign in',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 18),
                    if (_register) AppTextField(controller: _name, label: 'Name'),
                    AppTextField(controller: _email, label: 'Email', keyboardType: TextInputType.emailAddress),
                    AppTextField(controller: _password, label: 'Password', obscureText: true),
                    if (_message != null) ...[
                      const SizedBox(height: 10),
                      Text(_message!, style: const TextStyle(color: Color(0xffffc857))),
                    ],
                    const SizedBox(height: 18),
                    FilledButton(onPressed: _submitting ? null : _submit, child: Text(_submitting ? 'Please wait...' : (_register ? 'Create account' : 'Sign in'))),
                    TextButton(onPressed: _submitting ? null : () => setState(() { _register = !_register; _message = null; }), child: Text(_register ? 'Already registered? Sign in' : 'New here? Create account')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
