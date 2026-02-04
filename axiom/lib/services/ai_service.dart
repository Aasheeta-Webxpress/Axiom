import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String baseUrl = 'http://localhost:5000/api/ai';

  static Future<Map<String, dynamic>> generateAPIFromDescription(String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-api'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'];
        } else {
          throw Exception(data['error'] ?? 'Failed to generate API');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AI Service Error: $e');
    }
  }

  static Future<List<String>> getAPIImprovements(Map<String, dynamic> apiConfig) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/suggest-improvements'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'apiConfig': apiConfig,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return List<String>.from(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to get suggestions');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AI Service Error: $e');
    }
  }
}
