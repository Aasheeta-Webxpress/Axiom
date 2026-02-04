import 'dart:convert';
import 'package:http/http.dart' as http;

class ValidationService {
  static const String baseUrl = 'http://localhost:5000/api/validation';

  static Future<ValidationResult> validateField({
    required String fieldName,
    required String value,
    String? fieldType,
    Map<String, dynamic>? context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validate-field'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fieldName': fieldName,
          'value': value,
          'fieldType': fieldType ?? 'text',
          'context': context ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return ValidationResult.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Validation failed');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Validation Service Error: $e');
    }
  }

  static Future<FormValidationResult> validateForm({
    required Map<String, dynamic> formData,
    Map<String, dynamic>? formContext,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validate-form'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'formData': formData,
          'formContext': formContext ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return FormValidationResult.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Form validation failed');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Validation Service Error: $e');
    }
  }
}

// Data models
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String> suggestions;
  final double confidence;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.suggestions = const [],
    required this.confidence,
  });

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    return ValidationResult(
      isValid: json['isValid'] ?? false,
      errorMessage: json['errorMessage'],
      suggestions: List<String>.from(json['suggestions'] ?? []),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

class FormValidationResult {
  final bool isValid;
  final List<ValidationError> errors;
  final Map<String, ValidationResult> fieldResults;
  final double confidence;

  FormValidationResult({
    required this.isValid,
    this.errors = const [],
    required this.fieldResults,
    required this.confidence,
  });

  factory FormValidationResult.fromJson(Map<String, dynamic> json) {
    return FormValidationResult(
      isValid: json['isValid'] ?? false,
      errors: (json['errors'] as List?)
          ?.map((e) => ValidationError.fromJson(e))
          .toList() ?? [],
      fieldResults: (json['fieldResults'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, ValidationResult.fromJson(value)),
      ) ?? {},
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

class ValidationError {
  final String field;
  final String message;
  final List<String> suggestions;

  ValidationError({
    required this.field,
    required this.message,
    this.suggestions = const [],
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'] ?? '',
      message: json['message'] ?? '',
      suggestions: List<String>.from(json['suggestions'] ?? []),
    );
  }
}
