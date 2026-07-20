import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/user_model.dart';

class ApiService {
  final String baseUrl = AppConstants.baseUrl;

  Future<({UserModel user, String message})> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Login gagal');
    }

    final userJson = data['user'] as Map<String, dynamic>;

    return (
      user: UserModel.fromJson(userJson),
      message: data['message'] as String,
    );
  }

  Future<UserModel> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal mengambil data profil');
    }

    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }
}
