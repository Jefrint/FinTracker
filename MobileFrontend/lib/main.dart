import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'src/api.dart';
import 'src/models.dart';
import 'src/screens/auth_screen.dart';
import 'src/screens/home_screen.dart';
import 'src/widgets.dart';

const String configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

String get apiBaseUrl {
  if (configuredApiBaseUrl.isNotEmpty) return configuredApiBaseUrl;
  if (kIsWeb) return 'http://16.171.41.13:8081/api';
  if (defaultTargetPlatform == TargetPlatform.android) return 'http://16.171.41.13:8081/api';
  return 'http://16.171.41.13:8081/api';
}

void main() {
  runApp(const FinTrackerApp());
}

class FinTrackerApp extends StatefulWidget {
  const FinTrackerApp({super.key});

  @override
  State<FinTrackerApp> createState() => _FinTrackerAppState();
}

class _FinTrackerAppState extends State<FinTrackerApp> {
  final ApiClient _api = ApiClient();
  AuthSession? _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    // Session restore moved to auth screen flow; keep simple here.
    setState(() => _loading = false);
  }

  Future<void> _saveSession(AuthSession session) async {
    setState(() => _session = session);
  }

  Future<void> _logout() async {
    setState(() => _session = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinTracker',
      theme: ThemeData.dark(useMaterial3: true),
      home: _loading
          ? const LoadingScreen()
          : _session == null
              ? AuthScreen(api: _api, onLogin: (s) async { await _saveSession(s); })
              : HomeScreen(api: _api, session: _session!, onLogout: () async => _logout(), onSessionChanged: (s) => setState(() => _session = s)),
    );
  }
}
