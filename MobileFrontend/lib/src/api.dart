import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';
import '../main.dart' as app;

class ApiClient {
  Future<dynamic> _request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await http.Client().send(
      http.Request(method, Uri.parse('${app.apiBaseUrl}$path'))
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
    final data = await _request('/users/me', token: token) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<User> updateUser(
      String token, int id, String name, String email, String password) async {
    final data = await _request('/users/$id', method: 'PUT', token: token, body: {
      'name': name,
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<List<Asset>> assets(String token) async {
    final data = await _request('/assets', token: token) as List<dynamic>;
    return data.map((item) => Asset.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> createAsset(String token, String name, String type) async {
    await _request('/assets', method: 'POST', token: token, body: {
      'name': name,
      'type': type,
    });
  }

  Future<List<AppTransaction>> transactions(String token) async {
    final data = await _request('/transactions', token: token) as List<dynamic>;
    return data.map((item) => AppTransaction.fromJson(item as Map<String, dynamic>)).toList();
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
