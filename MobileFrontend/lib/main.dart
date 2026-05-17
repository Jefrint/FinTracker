import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String configuredApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: '',
);

String get apiBaseUrl {
  if (configuredApiBaseUrl.isNotEmpty) {
    return configuredApiBaseUrl;
  }

  if (kIsWeb) {
    return 'http://localhost:8081/api';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8081/api';
  }

  return 'http://localhost:8081/api';
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
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('fintracker.auth');

    if (raw == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final saved = AuthSession.fromJson(decoded);
      final freshUser = await _api.me(saved.token);
      setState(() {
        _session = AuthSession(token: saved.token, user: freshUser);
        _loading = false;
      });
    } catch (_) {
      await prefs.remove('fintracker.auth');
      setState(() => _loading = false);
    }
  }

  Future<void> _saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fintracker.auth', jsonEncode(session.toJson()));
    setState(() => _session = session);
  }

  Future<void> _logout() async {
    final token = _session?.token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fintracker.auth');
    setState(() => _session = null);

    if (token != null) {
      await _api.logout(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinTracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffd8ff5f),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xff050505),
        useMaterial3: true,
      ),
      home: _loading
          ? const LoadingScreen()
          : _session == null
              ? AuthScreen(api: _api, onLogin: _saveSession)
              : HomeScreen(
                  api: _api,
                  session: _session!,
                  onLogout: _logout,
                  onSessionChanged: (session) =>
                      setState(() => _session = session),
                ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

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
      if (mounted) {
        setState(() => _submitting = false);
      }
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
                    const Text('FinTracker',
                        style: TextStyle(color: Color(0xffd8ff5f))),
                    const SizedBox(height: 8),
                    Text(
                      _register ? 'Create account' : 'Sign in',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    const SizedBox(height: 18),
                    if (_register)
                      AppTextField(controller: _name, label: 'Name'),
                    AppTextField(
                        controller: _email,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress),
                    AppTextField(
                        controller: _password,
                        label: 'Password',
                        obscureText: true),
                    if (_message != null) ...[
                      const SizedBox(height: 10),
                      Text(_message!,
                          style: const TextStyle(color: Color(0xffffc857))),
                    ],
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: Text(_submitting
                          ? 'Please wait...'
                          : _register
                              ? 'Create account'
                              : 'Sign in'),
                    ),
                    TextButton(
                      onPressed: _submitting
                          ? null
                          : () => setState(() {
                                _register = !_register;
                                _message = null;
                              }),
                      child: Text(_register
                          ? 'Already registered? Sign in'
                          : 'New here? Create account'),
                    ),
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.api,
    required this.session,
    required this.onLogout,
    required this.onSessionChanged,
  });

  final ApiClient api;
  final AuthSession session;
  final Future<void> Function() onLogout;
  final ValueChanged<AuthSession> onSessionChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  List<Asset> _assets = [];
  List<AppTransaction> _transactions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        widget.api.assets(widget.session.token),
        widget.api.transactions(widget.session.token),
      ]);
      setState(() {
        _assets = results[0] as List<Asset>;
        _transactions = results[1] as List<AppTransaction>;
      });
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardView(
          assets: _assets,
          transactions: _transactions,
          loading: _loading,
          error: _error),
      AssetsView(
          api: widget.api,
          token: widget.session.token,
          assets: _assets,
          transactions: _transactions,
          onChanged: _load),
      TransactionsView(
          api: widget.api,
          token: widget.session.token,
          assets: _assets,
          transactions: _transactions,
          onChanged: _load),
      ProfileView(
        api: widget.api,
        session: widget.session,
        onLogout: widget.onLogout,
        onSessionChanged: widget.onSessionChanged,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(['Dashboard', 'Assets', 'Transactions', 'Profile'][_index]),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(
              onPressed: widget.onLogout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Assets'),
          NavigationDestination(icon: Icon(Icons.swap_vert), label: 'Activity'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({
    super.key,
    required this.assets,
    required this.transactions,
    required this.loading,
    required this.error,
  });

  final List<Asset> assets;
  final List<AppTransaction> transactions;
  final bool loading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final holdings = calculateHoldings(assets, transactions);
    final activeHoldings = holdings
        .where((item) => item.quantity != 0 || item.amount != 0)
        .toList();
    final netWorth =
        holdings.fold<double>(0, (total, item) => total + item.amount);

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (error != null) ErrorBanner(error!),
          StatGrid(
            stats: [
              StatData('Net worth', money(netWorth), 'Buys minus sells'),
              StatData('Assets', '${assets.length}', 'Tracked items'),
              StatData('Transactions', '${transactions.length}',
                  'Recorded activity'),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Asset holdings',
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : activeHoldings.isEmpty
                    ? const EmptyMessage('No holdings yet')
                    : Column(
                        children: activeHoldings.map((holding) {
                          return DataRowTile(
                            title: holding.asset.name,
                            subtitle:
                                '${holding.asset.type} - Qty ${number(holding.quantity)}',
                            trailing: money(holding.amount),
                          );
                        }).toList(),
                      ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Recent transactions',
            child: transactions.isEmpty
                ? const EmptyMessage('No transactions yet')
                : Column(
                    children: [...transactions]
                        .reversed
                        .take(8)
                        .map((transaction) => DataRowTile(
                              title: assetName(assets, transaction.assetId),
                              subtitle:
                                  '${transaction.type} - Qty ${number(transaction.quantity)}',
                              trailing: money(transactionAmount(transaction)),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class AssetsView extends StatefulWidget {
  const AssetsView({
    super.key,
    required this.api,
    required this.token,
    required this.assets,
    required this.transactions,
    required this.onChanged,
  });

  final ApiClient api;
  final String token;
  final List<Asset> assets;
  final List<AppTransaction> transactions;
  final Future<void> Function() onChanged;

  @override
  State<AssetsView> createState() => _AssetsViewState();
}

class _AssetsViewState extends State<AssetsView> {
  final _name = TextEditingController();
  String _type = 'STOCK';
  String? _message;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    try {
      await widget.api.createAsset(widget.token, _name.text, _type);
      _name.clear();
      await widget.onChanged();
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final holdings = calculateHoldings(widget.assets, widget.transactions);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: 'Create asset',
          child: Column(
            children: [
              AppTextField(controller: _name, label: 'Name'),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: ['STOCK', 'CRYPTO', 'ETF', 'CASH', 'OTHER']
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _type = value ?? 'STOCK'),
              ),
              if (_message != null) ErrorBanner(_message!),
              const SizedBox(height: 12),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: _create, child: const Text('Add asset'))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'All assets',
          child: holdings.isEmpty
              ? const EmptyMessage('No assets yet')
              : Column(
                  children: holdings
                      .map((holding) => DataRowTile(
                            title: holding.asset.name,
                            subtitle:
                                '${holding.asset.type} - Qty ${number(holding.quantity)}',
                            trailing: money(holding.amount),
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class TransactionsView extends StatefulWidget {
  const TransactionsView({
    super.key,
    required this.api,
    required this.token,
    required this.assets,
    required this.transactions,
    required this.onChanged,
  });

  final ApiClient api;
  final String token;
  final List<Asset> assets;
  final List<AppTransaction> transactions;
  final Future<void> Function() onChanged;

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  final _quantity = TextEditingController();
  final _price = TextEditingController();
  String _type = 'BUY';
  int? _assetId;
  String? _message;

  @override
  void dispose() {
    _quantity.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final assetId = _assetId ?? widget.assets.firstOrNull?.id;
    if (assetId == null) {
      setState(() => _message = 'Create an asset first.');
      return;
    }

    try {
      await widget.api.createTransaction(
        token: widget.token,
        assetId: assetId,
        type: _type,
        quantity: double.parse(_quantity.text),
        price: double.parse(_price.text),
      );
      _quantity.clear();
      _price.clear();
      await widget.onChanged();
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: 'Create transaction',
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                initialValue: _assetId ?? widget.assets.firstOrNull?.id,
                decoration: const InputDecoration(labelText: 'Asset'),
                items: widget.assets
                    .map((asset) => DropdownMenuItem(
                        value: asset.id, child: Text(asset.name)))
                    .toList(),
                onChanged: (value) => setState(() => _assetId = value),
              ),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: ['BUY', 'SELL', 'DIVIDEND', 'TRANSFER']
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _type = value ?? 'BUY'),
              ),
              AppTextField(
                  controller: _quantity,
                  label: 'Quantity',
                  keyboardType: TextInputType.number),
              AppTextField(
                  controller: _price,
                  label: 'Price',
                  keyboardType: TextInputType.number),
              if (_message != null) ErrorBanner(_message!),
              const SizedBox(height: 12),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: _create,
                      child: const Text('Add transaction'))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'History',
          child: widget.transactions.isEmpty
              ? const EmptyMessage('No transactions yet')
              : Column(
                  children: widget.transactions
                      .map((transaction) => DataRowTile(
                            title:
                                assetName(widget.assets, transaction.assetId),
                            subtitle:
                                '${transaction.type} - Qty ${number(transaction.quantity)}',
                            trailing: money(transactionAmount(transaction)),
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({
    super.key,
    required this.api,
    required this.session,
    required this.onLogout,
    required this.onSessionChanged,
  });

  final ApiClient api;
  final AuthSession session;
  final Future<void> Function() onLogout;
  final ValueChanged<AuthSession> onSessionChanged;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _password = TextEditingController();
  String? _message;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.session.user.name);
    _email = TextEditingController(text: widget.session.user.email);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      final user = await widget.api.updateUser(
        widget.session.token,
        widget.session.user.id,
        _name.text,
        _email.text,
        _password.text,
      );
      widget.onSessionChanged(
          AuthSession(token: widget.session.token, user: user));
      setState(() => _message = 'Profile updated.');
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: 'Account',
          child: Column(
            children: [
              AppTextField(controller: _name, label: 'Name'),
              AppTextField(controller: _email, label: 'Email'),
              AppTextField(
                  controller: _password,
                  label: 'New password',
                  obscureText: true),
              if (_message != null) ErrorBanner(_message!),
              const SizedBox(height: 12),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: _save, child: const Text('Save changes'))),
              TextButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ApiClient {
  Future<dynamic> _request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await http.Client().send(
      http.Request(method, Uri.parse('$apiBaseUrl$path'))
        ..headers.addAll({
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        })
        ..body = body == null ? '' : jsonEncode(body),
    );
    final text = await response.stream.bytesToString();
    final decoded = text.isEmpty ? null : jsonDecode(text);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (decoded is Map<String, dynamic>) {
        throw Exception(decoded['message'] ?? 'Request failed');
      }
      throw Exception('Request failed with status ${response.statusCode}');
    }

    return decoded;
  }

  Future<AuthSession> login(String email, String password) async {
    final data = await _request('/auth/login', method: 'POST', body: {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;
    return AuthSession.fromLogin(data);
  }

  Future<void> register(String name, String email, String password) async {
    await _request('/auth/register', method: 'POST', body: {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<void> logout(String token) async {
    try {
      await _request('/auth/logout', method: 'POST', token: token);
    } catch (_) {}
  }

  Future<User> me(String token) async {
    final data =
        await _request('/users/me', token: token) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<User> updateUser(
      String token, int id, String name, String email, String password) async {
    final data =
        await _request('/users/$id', method: 'PUT', token: token, body: {
      'name': name,
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<List<Asset>> assets(String token) async {
    final data = await _request('/assets', token: token) as List<dynamic>;
    return data
        .map((item) => Asset.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createAsset(String token, String name, String type) async {
    await _request('/assets', method: 'POST', token: token, body: {
      'name': name,
      'type': type,
    });
  }

  Future<List<AppTransaction>> transactions(String token) async {
    final data = await _request('/transactions', token: token) as List<dynamic>;
    return data
        .map((item) => AppTransaction.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createTransaction({
    required String token,
    required int assetId,
    required String type,
    required double quantity,
    required double price,
  }) async {
    await _request('/transactions', method: 'POST', token: token, body: {
      'assetId': assetId,
      'type': type,
      'quantity': quantity,
      'price': price,
      'date': DateTime.now().toIso8601String().substring(0, 10),
    });
  }
}

class User {
  const User({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final User user;

  factory AuthSession.fromLogin(Map<String, dynamic> json) {
    return AuthSession(
        token: json['token'] as String, user: User.fromJson(json));
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {'token': token, 'user': user.toJson()};
}

class Asset {
  const Asset({required this.id, required this.name, required this.type});

  final int id;
  final String name;
  final String type;

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
        id: json['id'] as int,
        name: json['name'] as String,
        type: json['type'] as String);
  }
}

class AppTransaction {
  const AppTransaction({
    required this.id,
    required this.quantity,
    required this.price,
    required this.type,
    required this.assetId,
  });

  final int id;
  final double quantity;
  final double price;
  final String type;
  final int assetId;

  factory AppTransaction.fromJson(Map<String, dynamic> json) {
    return AppTransaction(
      id: json['id'] as int,
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      type: json['type'] as String,
      assetId: json['assetId'] as int,
    );
  }
}

class AssetHolding {
  const AssetHolding({
    required this.asset,
    required this.quantity,
    required this.amount,
  });

  final Asset asset;
  final double quantity;
  final double amount;
}

List<AssetHolding> calculateHoldings(
    List<Asset> assets, List<AppTransaction> transactions) {
  return assets.map((asset) {
    var quantity = 0.0;
    var amount = 0.0;

    for (final transaction
        in transactions.where((item) => item.assetId == asset.id)) {
      final sign = transaction.type == 'SELL'
          ? -1.0
          : transaction.type == 'BUY'
              ? 1.0
              : 0.0;
      quantity += sign * transaction.quantity;
      amount += sign * transaction.quantity * transaction.price;
    }

    return AssetHolding(asset: asset, quantity: quantity, amount: amount);
  }).toList();
}

double transactionAmount(AppTransaction transaction) {
  final sign = transaction.type == 'SELL'
      ? -1.0
      : transaction.type == 'BUY'
          ? 1.0
          : 0.0;
  return sign * transaction.quantity * transaction.price;
}

String assetName(List<Asset> assets, int id) {
  return assets.where((asset) => asset.id == id).firstOrNull?.name ??
      'Asset #$id';
}

String money(double value) => '\$${value.toStringAsFixed(2)}';

String number(double value) {
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 4);
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff151513),
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class StatData {
  const StatData(this.label, this.value, this.detail);

  final String label;
  final String value;
  final String detail;
}

class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.stats});

  final List<StatData> stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stats
          .map(
            (stat) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stat.label,
                              style: const TextStyle(color: Color(0xffaaa59a))),
                          const SizedBox(height: 6),
                          Text(stat.value,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900)),
                          Text(stat.detail,
                              style: const TextStyle(color: Color(0xffaaa59a))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class DataRowTile extends StatelessWidget {
  const DataRowTile(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.trailing});

  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing:
          Text(trailing, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class EmptyMessage extends StatelessWidget {
  const EmptyMessage(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Center(
          child:
              Text(message, style: const TextStyle(color: Color(0xffaaa59a)))),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x22ff6b57),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x44ff6b57)),
      ),
      child: Text(message),
    );
  }
}
