import 'dart:convert';
import 'package:http/http.dart' as http;

import 'session_manager.dart';

class ApiService {
  static const String baseUrl = "http://100.25.213.209:8000";

  Future<String> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/api/token/");
    final body = jsonEncode({'username': username, 'password': password});
    print(body);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access']; // Assuming token is returned on success.
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await SessionManager().getToken();

    if (token == null) {
      throw Exception("No authentication token found. Please log in again.");
    }

    final url = Uri.parse("$baseUrl/api/user-details/");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch user profile: ${response.body}");
    }
  }

  Future<void> signup(String email, String username, String password) async {
    final url = Uri.parse("$baseUrl/api/signup/");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'email': email, 'username': username, 'password': password}),
    );

    if (response.statusCode != 201) {
      throw Exception("Signup failed: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> fetchChatMessages(String query) async {
    // Retrieve the saved token from SharedPreferences
    final token = await SessionManager().getToken();

    if (token == null) {
      throw Exception("No authentication token found. Please log in again.");
    }

    print("Printing token: $token");

    final url = Uri.parse("$baseUrl/test/");
    final body = jsonEncode({'query': query});

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add Bearer token for authentication
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data; // Returns the chat message data
    } else {
      throw Exception("Failed to fetch chat messages: ${response.body}");
    }
  }
}
