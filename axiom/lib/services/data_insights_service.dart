import 'dart:convert';
import 'package:http/http.dart' as http;

class DataInsightsService {
  static const String baseUrl = 'http://localhost:5000/api/data-insights';

  static Future<FormCompletionInsights> getFormCompletionInsights({
    required String projectId,
    required String formId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/form-completion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'projectId': projectId, 'formId': formId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return FormCompletionInsights.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to get form completion insights');
        }
      }
      throw Exception('Failed to get form completion insights');
    } catch (e) {
      throw Exception('Data Insights Service Error: $e');
    }
  }

  static Future<DataPatternRecognition> getDataPatternRecognition({
    required String projectId,
    required String dataType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/data-patterns'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'projectId': projectId, 'dataType': dataType}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return DataPatternRecognition.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to analyze data patterns');
        }
      }
      throw Exception('Failed to analyze data patterns');
    } catch (e) {
      throw Exception('Data Insights Service Error: $e');
    }
  }

  static Future<PerformanceRecommendations> getPerformanceRecommendations({
    required String projectId,
    List<Map<String, dynamic>>? apiUsage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/performance-recommendations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'projectId': projectId,
          'apiUsage': apiUsage ?? [],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return PerformanceRecommendations.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to get performance recommendations');
        }
      }
      throw Exception('Failed to get performance recommendations');
    } catch (e) {
      throw Exception('Data Insights Service Error: $e');
    }
  }
}

// Data models
class FormCompletionInsights {
  final double overallCompletionRate;
  final List<DropOffPoint> dropOffPoints;
  final List<Recommendation> recommendations;

  FormCompletionInsights({
    required this.overallCompletionRate,
    required this.dropOffPoints,
    required this.recommendations,
  });

  factory FormCompletionInsights.fromJson(Map<String, dynamic> json) {
    return FormCompletionInsights(
      overallCompletionRate: (json['completionRate']['overall'] ?? 0.0).toDouble(),
      dropOffPoints: (json['dropOffPoints'] as List?)
          ?.map((d) => DropOffPoint.fromJson(d))
          .toList() ?? [],
      recommendations: (json['recommendations'] as List?)
          ?.map((r) => Recommendation.fromJson(r))
          .toList() ?? [],
    );
  }
}

class DropOffPoint {
  final String fieldName;
  final double dropOffRate;
  final String severity;
  final List<String> suggestions;

  DropOffPoint({
    required this.fieldName,
    required this.dropOffRate,
    required this.severity,
    required this.suggestions,
  });

  factory DropOffPoint.fromJson(Map<String, dynamic> json) {
    return DropOffPoint(
      fieldName: json['fieldName'] ?? '',
      dropOffRate: (json['dropOffRate'] ?? 0.0).toDouble(),
      severity: json['severity'] ?? 'low',
      suggestions: List<String>.from(json['suggestions'] ?? []),
    );
  }
}

class Recommendation {
  final String type;
  final String priority;
  final String title;
  final String description;

  Recommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      type: json['type'] ?? '',
      priority: json['priority'] ?? 'medium',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class DataPatternRecognition {
  final List<DataPattern> detectedPatterns;
  final List<FieldTypeSuggestion> suggestedFieldTypes;

  DataPatternRecognition({
    required this.detectedPatterns,
    required this.suggestedFieldTypes,
  });

  factory DataPatternRecognition.fromJson(Map<String, dynamic> json) {
    return DataPatternRecognition(
      detectedPatterns: (json['detectedPatterns'] as List?)
          ?.map((p) => DataPattern.fromJson(p))
          .toList() ?? [],
      suggestedFieldTypes: (json['suggestedFieldTypes'] as List?)
          ?.map((s) => FieldTypeSuggestion.fromJson(s))
          .toList() ?? [],
    );
  }
}

class DataPattern {
  final String patternType;
  final double confidence;
  final List<String> examples;

  DataPattern({
    required this.patternType,
    required this.confidence,
    required this.examples,
  });

  factory DataPattern.fromJson(Map<String, dynamic> json) {
    return DataPattern(
      patternType: json['patternType'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      examples: List<String>.from(json['examples'] ?? []),
    );
  }
}

class FieldTypeSuggestion {
  final String fieldName;
  final String suggestedType;
  final double confidence;

  FieldTypeSuggestion({
    required this.fieldName,
    required this.suggestedType,
    required this.confidence,
  });

  factory FieldTypeSuggestion.fromJson(Map<String, dynamic> json) {
    return FieldTypeSuggestion(
      fieldName: json['fieldName'] ?? '',
      suggestedType: json['suggestedType'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

class PerformanceRecommendations {
  final Map<String, dynamic> apiOptimizations;
  final Map<String, dynamic> cachingStrategies;
  final Map<String, dynamic> databaseOptimizations;
  final Map<String, dynamic> frontendOptimizations;

  PerformanceRecommendations({
    required this.apiOptimizations,
    required this.cachingStrategies,
    required this.databaseOptimizations,
    required this.frontendOptimizations,
  });

  factory PerformanceRecommendations.fromJson(Map<String, dynamic> json) {
    return PerformanceRecommendations(
      apiOptimizations: json['apiOptimizations'] ?? {},
      cachingStrategies: json['cachingStrategies'] ?? {},
      databaseOptimizations: json['databaseOptimizations'] ?? {},
      frontendOptimizations: json['frontendOptimizations'] ?? {},
    );
  }
}
