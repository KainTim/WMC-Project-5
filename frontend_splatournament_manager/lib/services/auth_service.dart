import 'dart:convert';
import 'package:frontend_splatournament_manager/main.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = SplatournamentApp.baseUrl;
  Future<Map<String, dynamic>> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Registration failed');
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Login failed');
    }
  }
}

