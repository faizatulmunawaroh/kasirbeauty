import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _username;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  bool get isLoading => _isLoading;

  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // For demo purposes, accept any username/password combination
      // In a real app, this would make an API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      if (username == 'admin' && password == 'admin') {
        _isAuthenticated = true;
        _username = username;

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('username', username);

        notifyListeners();
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _username = null;

    // Clear from local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAuthenticated');
    await prefs.remove('username');

    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _username = prefs.getString('username');
    notifyListeners();
  }

  Future<void> register(String username, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      // For demo purposes, simulate registration
      await Future.delayed(const Duration(seconds: 1));

      if (username.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        _isAuthenticated = true;
        _username = username;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('username', username);

        notifyListeners();
      } else {
        throw Exception('Invalid registration data');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }

    _isLoading = false;
    notifyListeners();
  }
}