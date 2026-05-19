import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api, required this.session, required this.onLogout, required this.onSessionChanged});

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
    setState(() { _loading = true; _error = null; });
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
      DashboardView(assets: _assets, transactions: _transactions, loading: _loading, error: _error),
      AssetsView(api: widget.api, token: widget.session.token, assets: _assets, transactions: _transactions, onChanged: _load),
      TransactionsView(api: widget.api, token: widget.session.token, assets: _assets, transactions: _transactions, onChanged: _load),
      ProfileView(api: widget.api, session: widget.session, onLogout: widget.onLogout, onSessionChanged: widget.onSessionChanged),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(['Dashboard', 'Assets', 'Transactions', 'Profile'][_index]),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: widget.onLogout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Assets'),
          NavigationDestination(icon: Icon(Icons.swap_vert), label: 'Activity'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key, required this.assets, required this.transactions, required this.loading, required this.error});

  final List<Asset> assets;
  final List<AppTransaction> transactions;
  final bool loading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final holdings = calculateHoldings(assets, transactions);
    final activeHoldings = holdings.where((item) => item.quantity != 0 || item.amount != 0).toList();
    final netWorth = holdings.fold<double>(0, (total, item) => total + item.amount);

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (error != null) ErrorBanner(error!),
          StatGrid(stats: [
            StatData('Net worth', money(netWorth), 'Buys minus sells'),
            StatData('Assets', '${assets.length}', 'Tracked items'),
            StatData('Transactions', '${transactions.length}', 'Recorded activity'),
          ]),
          const SizedBox(height: 16),
          SectionCard(title: 'Asset holdings', child: loading ? const Center(child: CircularProgressIndicator()) : (activeHoldings.isEmpty ? const EmptyMessage('No holdings yet') : Column(children: activeHoldings.map((holding) => DataRowTile(title: holding.asset.name, subtitle: '${holding.asset.type} - Qty ${number(holding.quantity)}', trailing: money(holding.amount))).toList()))),
          const SizedBox(height: 16),
          SectionCard(title: 'Recent transactions', child: transactions.isEmpty ? const EmptyMessage('No transactions yet') : Column(children: [...transactions].reversed.take(8).map((transaction) => DataRowTile(title: assetName(assets, transaction.assetId), subtitle: '${transaction.type} - Qty ${number(transaction.quantity)}', trailing: money(transactionAmount(transaction)))).toList())),
        ],
      ),
    );
  }
}

class AssetsView extends StatefulWidget {
  const AssetsView({super.key, required this.api, required this.token, required this.assets, required this.transactions, required this.onChanged});

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
        SectionCard(title: 'Create asset', child: Column(children: [AppTextField(controller: _name, label: 'Name'), DropdownButtonFormField<String>(initialValue: _type, decoration: const InputDecoration(labelText: 'Type'), items: ['STOCK', 'CRYPTO', 'ETF', 'CASH', 'OTHER'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(), onChanged: (value) => setState(() => _type = value ?? 'STOCK')), if (_message != null) ErrorBanner(_message!), const SizedBox(height: 12), SizedBox(width: double.infinity, child: FilledButton(onPressed: _create, child: const Text('Add asset')))])),
        const SizedBox(height: 16),
        SectionCard(title: 'All assets', child: holdings.isEmpty ? const EmptyMessage('No assets yet') : Column(children: holdings.map((holding) => DataRowTile(title: holding.asset.name, subtitle: '${holding.asset.type} - Qty ${number(holding.quantity)}', trailing: money(holding.amount))).toList())),
      ],
    );
  }
}

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key, required this.api, required this.token, required this.assets, required this.transactions, required this.onChanged});

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
      await widget.api.createTransaction(token: widget.token, assetId: assetId, type: _type, quantity: double.parse(_quantity.text), price: double.parse(_price.text));
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
        SectionCard(title: 'Create transaction', child: Column(children: [DropdownButtonFormField<int>(initialValue: _assetId ?? widget.assets.firstOrNull?.id, decoration: const InputDecoration(labelText: 'Asset'), items: widget.assets.map((asset) => DropdownMenuItem(value: asset.id, child: Text(asset.name))).toList(), onChanged: (value) => setState(() => _assetId = value)), DropdownButtonFormField<String>(initialValue: _type, decoration: const InputDecoration(labelText: 'Type'), items: ['BUY', 'SELL', 'DIVIDEND', 'TRANSFER'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(), onChanged: (value) => setState(() => _type = value ?? 'BUY')), AppTextField(controller: _quantity, label: 'Quantity', keyboardType: TextInputType.number), AppTextField(controller: _price, label: 'Price', keyboardType: TextInputType.number), if (_message != null) ErrorBanner(_message!), const SizedBox(height: 12), SizedBox(width: double.infinity, child: FilledButton(onPressed: _create, child: const Text('Add transaction')))])),
        const SizedBox(height: 16),
        SectionCard(title: 'History', child: widget.transactions.isEmpty ? const EmptyMessage('No transactions yet') : Column(children: widget.transactions.map((transaction) => DataRowTile(title: assetName(widget.assets, transaction.assetId), subtitle: '${transaction.type} - Qty ${number(transaction.quantity)}', trailing: money(transactionAmount(transaction)))).toList())),
      ],
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.api, required this.session, required this.onLogout, required this.onSessionChanged});

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
      final user = await widget.api.updateUser(widget.session.token, widget.session.user.id, _name.text, _email.text, _password.text);
      widget.onSessionChanged(AuthSession(token: widget.session.token, user: user));
      setState(() => _message = 'Profile updated.');
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [SectionCard(title: 'Account', child: Column(children: [AppTextField(controller: _name, label: 'Name'), AppTextField(controller: _email, label: 'Email'), AppTextField(controller: _password, label: 'New password', obscureText: true), if (_message != null) ErrorBanner(_message!), const SizedBox(height: 12), SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text('Save changes'))), TextButton.icon(onPressed: widget.onLogout, icon: const Icon(Icons.logout), label: const Text('Sign out'))]))]);
  }
}
