import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoggedIn = false;
  String? _username;
  int? _userId;
  String? _error;
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  int? get userId => _userId;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.login(username, password);
      
      final token = user['token'];
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
      }

      _isLoggedIn = true;
      _username = user['username'];
      _userId = user['id'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.register(username, password);

      final token = user['token'];
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
      }

      _isLoggedIn = true;
      _username = user['username'];
      _userId = user['id'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _username = null;
    _userId = null;
    _error = null;
    await _storage.delete(key: 'jwt_token');
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      if (JwtDecoder.isExpired(token)) {
        await logout();
      } else {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        _isLoggedIn = true;
        _userId = decodedToken['id'];
        _username = decodedToken['username'];
        notifyListeners();
      }
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
