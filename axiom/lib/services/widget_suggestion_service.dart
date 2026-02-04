import 'dart:convert';
import 'package:http/http.dart' as http;

class WidgetSuggestionService {
  static const String baseUrl = 'http://localhost:5000/api/widget-suggestions';

  static Future<WidgetSuggestions> getWidgetSuggestions({
    required Map<String, dynamic> projectContext,
    required List<Map<String, dynamic>> existingWidgets,
    String userIntent = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/suggestions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'projectContext': projectContext,
          'existingWidgets': existingWidgets,
          'userIntent': userIntent,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return WidgetSuggestions.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to get suggestions');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Widget Suggestion Service Error: $e');
    }
  }

  static Future<WidgetOptimizations> getWidgetOptimizations({
    required List<Map<String, dynamic>> widgets,
    required Map<String, dynamic> projectContext,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/optimizations'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'widgets': widgets,
          'projectContext': projectContext,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return WidgetOptimizations.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to get optimizations');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Widget Suggestion Service Error: $e');
    }
  }

  static Future<ProjectTypeSuggestions> getProjectTypeSuggestions({
    required String projectName,
    String projectDescription = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/project-type'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'projectName': projectName,
          'projectDescription': projectDescription,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return ProjectTypeSuggestions.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to get project type suggestions');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Widget Suggestion Service Error: $e');
    }
  }
}

// Data models
class WidgetSuggestions {
  final List<WidgetSuggestion> suggestions;
  final List<LayoutSuggestion> layoutSuggestions;
  final List<String> nextSteps;

  WidgetSuggestions({
    required this.suggestions,
    required this.layoutSuggestions,
    required this.nextSteps,
  });

  factory WidgetSuggestions.fromJson(Map<String, dynamic> json) {
    return WidgetSuggestions(
      suggestions: (json['suggestions'] as List?)
          ?.map((s) => WidgetSuggestion.fromJson(s))
          .toList() ?? [],
      layoutSuggestions: (json['layoutSuggestions'] as List?)
          ?.map((l) => LayoutSuggestion.fromJson(l))
          .toList() ?? [],
      nextSteps: List<String>.from(json['nextSteps'] ?? []),
    );
  }
}

class WidgetSuggestion {
  final String widgetType;
  final String reason;
  final String priority;
  final Map<String, dynamic> properties;
  final Map<String, dynamic> position;

  WidgetSuggestion({
    required this.widgetType,
    required this.reason,
    required this.priority,
    required this.properties,
    required this.position,
  });

  factory WidgetSuggestion.fromJson(Map<String, dynamic> json) {
    return WidgetSuggestion(
      widgetType: json['widgetType'] ?? '',
      reason: json['reason'] ?? '',
      priority: json['priority'] ?? 'medium',
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      position: Map<String, dynamic>.from(json['position'] ?? {}),
    );
  }
}

class LayoutSuggestion {
  final String type;
  final String description;
  final List<String> widgets;

  LayoutSuggestion({
    required this.type,
    required this.description,
    required this.widgets,
  });

  factory LayoutSuggestion.fromJson(Map<String, dynamic> json) {
    return LayoutSuggestion(
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      widgets: List<String>.from(json['widgets'] ?? []),
    );
  }
}

class WidgetOptimizations {
  final List<Optimization> optimizations;
  final List<AccessibilityIssue> accessibilityIssues;
  final List<String> performanceTips;

  WidgetOptimizations({
    required this.optimizations,
    this.accessibilityIssues = const [],
    this.performanceTips = const [],
  });

  factory WidgetOptimizations.fromJson(Map<String, dynamic> json) {
    return WidgetOptimizations(
      optimizations: (json['optimizations'] as List?)
          ?.map((o) => Optimization.fromJson(o))
          .toList() ?? [],
      accessibilityIssues: (json['accessibilityIssues'] as List?)
          ?.map((a) => AccessibilityIssue.fromJson(a))
          .toList() ?? [],
      performanceTips: List<String>.from(json['performanceTips'] ?? []),
    );
  }
}

class Optimization {
  final String? widgetId;
  final String type;
  final String suggestion;
  final String priority;
  final String before;
  final String after;

  Optimization({
    this.widgetId,
    required this.type,
    required this.suggestion,
    required this.priority,
    required this.before,
    required this.after,
  });

  factory Optimization.fromJson(Map<String, dynamic> json) {
    return Optimization(
      widgetId: json['widgetId'],
      type: json['type'] ?? '',
      suggestion: json['suggestion'] ?? '',
      priority: json['priority'] ?? 'medium',
      before: json['before'] ?? '',
      after: json['after'] ?? '',
    );
  }
}

class AccessibilityIssue {
  final String widgetId;
  final String issue;
  final String solution;

  AccessibilityIssue({
    required this.widgetId,
    required this.issue,
    required this.solution,
  });

  factory AccessibilityIssue.fromJson(Map<String, dynamic> json) {
    return AccessibilityIssue(
      widgetId: json['widgetId'] ?? '',
      issue: json['issue'] ?? '',
      solution: json['solution'] ?? '',
    );
  }
}

class ProjectTypeSuggestions {
  final String projectType;
  final double confidence;
  final List<CommonWidget> commonWidgets;
  final String layoutPattern;
  final String colorScheme;

  ProjectTypeSuggestions({
    required this.projectType,
    required this.confidence,
    required this.commonWidgets,
    required this.layoutPattern,
    required this.colorScheme,
  });

  factory ProjectTypeSuggestions.fromJson(Map<String, dynamic> json) {
    return ProjectTypeSuggestions(
      projectType: json['projectType'] ?? 'other',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      commonWidgets: (json['commonWidgets'] as List?)
          ?.map((w) => CommonWidget.fromJson(w))
          .toList() ?? [],
      layoutPattern: json['layoutPattern'] ?? 'single-column',
      colorScheme: json['colorScheme'] ?? 'professional',
    );
  }
}

class CommonWidget {
  final String widgetType;
  final String purpose;
  final Map<String, dynamic> properties;

  CommonWidget({
    required this.widgetType,
    required this.purpose,
    required this.properties,
  });

  factory CommonWidget.fromJson(Map<String, dynamic> json) {
    return CommonWidget(
      widgetType: json['widgetType'] ?? '',
      purpose: json['purpose'] ?? '',
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
    );
  }
}
