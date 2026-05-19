extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull {
    if (isEmpty) return null;
    return first;
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
    return AuthSession(token: json['token'] as String, user: User.fromJson(json));
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
  const AssetHolding({required this.asset, required this.quantity, required this.amount});

  final Asset asset;
  final double quantity;
  final double amount;
}

List<AssetHolding> calculateHoldings(List<Asset> assets, List<AppTransaction> transactions) {
  return assets.map((asset) {
    var quantity = 0.0;
    var amount = 0.0;

    for (final transaction in transactions.where((item) => item.assetId == asset.id)) {
      final sign = transaction.type == 'SELL' ? -1.0 : (transaction.type == 'BUY' ? 1.0 : 0.0);
      quantity += sign * transaction.quantity;
      amount += sign * transaction.quantity * transaction.price;
    }

    return AssetHolding(asset: asset, quantity: quantity, amount: amount);
  }).toList();
}

double transactionAmount(AppTransaction transaction) {
  final sign = transaction.type == 'SELL' ? -1.0 : (transaction.type == 'BUY' ? 1.0 : 0.0);
  return sign * transaction.quantity * transaction.price;
}

String assetName(List<Asset> assets, int id) {
  return assets.where((asset) => asset.id == id).firstOrNull?.name ?? 'Asset #$id';
}

String money(double value) => '\$${value.toStringAsFixed(2)}';

String number(double value) {
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 4);
}
