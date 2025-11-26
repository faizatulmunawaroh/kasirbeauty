import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // For demo purposes, accept any email/password combination
      // In a real app, this would make an API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      if (email.isNotEmpty && password.isNotEmpty) {
        _isAuthenticated = true;
        _userEmail = email;

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('userEmail', email);

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
    _userEmail = null;

    // Clear from local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAuthenticated');
    await prefs.remove('userEmail');

    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userEmail = prefs.getString('userEmail');
    notifyListeners();
  }

  Future<void> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      // For demo purposes, simulate registration
      await Future.delayed(const Duration(seconds: 1));

      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        _isAuthenticated = true;
        _userEmail = email;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('userEmail', email);

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