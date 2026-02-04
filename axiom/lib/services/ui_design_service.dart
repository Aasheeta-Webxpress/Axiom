import 'dart:convert';
import 'package:http/http.dart' as http;

class UIDesignService {
  static const String baseUrl = 'http://localhost:5000/api/ui-design';

  static Future<LayoutSuggestions> getLayoutSuggestions({
    required List<Map<String, dynamic>> widgets,
    required Map<String, double> canvasSize,
    String projectType = 'general',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/layout-suggestions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'widgets': widgets,
          'canvasSize': canvasSize,
          'projectType': projectType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return LayoutSuggestions.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to get layout suggestions');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('UI Design Service Error: $e');
    }
  }

  static Future<ColorSchemeSuggestions> getColorSchemeSuggestions({
    required String projectType,
    Map<String, String>? existingColors,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/color-schemes'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'projectType': projectType,
          'existingColors': existingColors ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return ColorSchemeSuggestions.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to get color schemes');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('UI Design Service Error: $e');
    }
  }

  static Future<TypographySuggestions> getTypographySuggestions({
    required String projectType,
    Map<String, dynamic>? currentFonts,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/typography'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'projectType': projectType,
          'currentFonts': currentFonts ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return TypographySuggestions.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to get typography suggestions');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('UI Design Service Error: $e');
    }
  }
}

// Data models
class LayoutSuggestions {
  final LayoutAnalysis layoutAnalysis;
  final List<LayoutImprovement> suggestions;
  final List<AutoLayout> autoLayouts;

  LayoutSuggestions({
    required this.layoutAnalysis,
    required this.suggestions,
    required this.autoLayouts,
  });

  factory LayoutSuggestions.fromJson(Map<String, dynamic> json) {
    return LayoutSuggestions(
      layoutAnalysis: LayoutAnalysis.fromJson(json['layoutAnalysis']),
      suggestions: (json['suggestions'] as List?)
          ?.map((s) => LayoutImprovement.fromJson(s))
          .toList() ?? [],
      autoLayouts: (json['autoLayouts'] as List?)
          ?.map((l) => AutoLayout.fromJson(l))
          .toList() ?? [],
    );
  }
}

class LayoutAnalysis {
  final int widgetCount;
  final double density;
  final AlignmentInfo alignment;
  final SpacingInfo spacing;
  final HierarchyInfo hierarchy;
  final BalanceInfo balance;

  LayoutAnalysis({
    required this.widgetCount,
    required this.density,
    required this.alignment,
    required this.spacing,
    required this.hierarchy,
    required this.balance,
  });

  factory LayoutAnalysis.fromJson(Map<String, dynamic> json) {
    return LayoutAnalysis(
      widgetCount: json['widgetCount'] ?? 0,
      density: (json['density'] ?? 0.0).toDouble(),
      alignment: AlignmentInfo.fromJson(json['alignment']),
      spacing: SpacingInfo.fromJson(json['spacing']),
      hierarchy: HierarchyInfo.fromJson(json['hierarchy']),
      balance: BalanceInfo.fromJson(json['balance']),
    );
  }
}

class AlignmentInfo {
  final double score;
  final int alignedCount;
  final int totalCount;

  AlignmentInfo({
    required this.score,
    required this.alignedCount,
    required this.totalCount,
  });

  factory AlignmentInfo.fromJson(Map<String, dynamic> json) {
    return AlignmentInfo(
      score: (json['score'] ?? 0.0).toDouble(),
      alignedCount: json['alignedCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
    );
  }
}

class SpacingInfo {
  final double? consistency;
  final double? average;
  final double? variance;

  SpacingInfo({
    this.consistency,
    this.average,
    this.variance,
  });

  factory SpacingInfo.fromJson(Map<String, dynamic> json) {
    return SpacingInfo(
      consistency: json['consistency']?.toDouble(),
      average: json['average']?.toDouble(),
      variance: json['variance']?.toDouble(),
    );
  }
}

class HierarchyInfo {
  final double clarity;
  final bool hasHeadings;
  final bool hasBody;
  final int headingCount;

  HierarchyInfo({
    required this.clarity,
    required this.hasHeadings,
    required this.hasBody,
    required this.headingCount,
  });

  factory HierarchyInfo.fromJson(Map<String, dynamic> json) {
    return HierarchyInfo(
      clarity: (json['clarity'] ?? 0.0).toDouble(),
      hasHeadings: json['hasHeadings'] ?? false,
      hasBody: json['hasBody'] ?? false,
      headingCount: json['headingCount'] ?? 0,
    );
  }
}

class BalanceInfo {
  final double score;
  final int leftWeight;
  final int rightWeight;
  final bool isBalanced;

  BalanceInfo({
    required this.score,
    required this.leftWeight,
    required this.rightWeight,
    required this.isBalanced,
  });

  factory BalanceInfo.fromJson(Map<String, dynamic> json) {
    return BalanceInfo(
      score: (json['score'] ?? 0.0).toDouble(),
      leftWeight: json['leftWeight'] ?? 0,
      rightWeight: json['rightWeight'] ?? 0,
      isBalanced: json['isBalanced'] ?? false,
    );
  }
}

class LayoutImprovement {
  final String type;
  final String priority;
  final String suggestion;
  final String action;
  final String impact;

  LayoutImprovement({
    required this.type,
    required this.priority,
    required this.suggestion,
    required this.action,
    required this.impact,
  });

  factory LayoutImprovement.fromJson(Map<String, dynamic> json) {
    return LayoutImprovement(
      type: json['type'] ?? '',
      priority: json['priority'] ?? 'medium',
      suggestion: json['suggestion'] ?? '',
      action: json['action'] ?? '',
      impact: json['impact'] ?? '',
    );
  }
}

class AutoLayout {
  final String name;
  final String description;
  final List<WidgetPosition> positions;
  final double suitability;
  final String? preview;

  AutoLayout({
    required this.name,
    required this.description,
    required this.positions,
    required this.suitability,
    this.preview,
  });

  factory AutoLayout.fromJson(Map<String, dynamic> json) {
    return AutoLayout(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      positions: (json['positions'] as List?)
          ?.map((p) => WidgetPosition.fromJson(p))
          .toList() ?? [],
      suitability: (json['suitability'] ?? 0.0).toDouble(),
      preview: json['preview'],
    );
  }
}

class WidgetPosition {
  final String id;
  final double x;
  final double y;
  final double width;
  final double height;

  WidgetPosition({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory WidgetPosition.fromJson(Map<String, dynamic> json) {
    return WidgetPosition(
      id: json['id'] ?? '',
      x: (json['x'] ?? 0.0).toDouble(),
      y: (json['y'] ?? 0.0).toDouble(),
      width: (json['width'] ?? 0.0).toDouble(),
      height: (json['height'] ?? 0.0).toDouble(),
    );
  }
}

class ColorSchemeSuggestions {
  final List<UIColorScheme> recommendedSchemes;
  final List<AccessibilityScore> accessibilityScore;
  final CurrentSchemeAnalysis currentScheme;

  ColorSchemeSuggestions({
    required this.recommendedSchemes,
    required this.accessibilityScore,
    required this.currentScheme,
  });

  factory ColorSchemeSuggestions.fromJson(Map<String, dynamic> json) {
    return ColorSchemeSuggestions(
      recommendedSchemes: (json['recommendedSchemes'] as List?)
          ?.map((s) => UIColorScheme.fromJson(s))
          .toList() ?? [],
      accessibilityScore: (json['accessibilityScore'] as List?)
          ?.map((a) => AccessibilityScore.fromJson(a))
          .toList() ?? [],
      currentScheme: CurrentSchemeAnalysis.fromJson(json['currentScheme']),
    );
  }
}

class UIColorScheme {
  final String name;
  final String primary;
  final String secondary;
  final String accent;
  final String background;
  final String text;
  final String description;
  final String accessibility;
  final String mood;
  final bool isDynamic;
  final Map<String, dynamic>? variations;

  UIColorScheme({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.text,
    required this.description,
    required this.accessibility,
    required this.mood,
    this.isDynamic = false,
    this.variations,
  });

  factory UIColorScheme.fromJson(Map<String, dynamic> json) {
    return UIColorScheme(
      name: json['name'] ?? '',
      primary: json['primary'] ?? '',
      secondary: json['secondary'] ?? '',
      accent: json['accent'] ?? '',
      background: json['background'] ?? '',
      text: json['text'] ?? '',
      description: json['description'] ?? '',
      accessibility: json['accessibility'] ?? '',
      mood: json['mood'] ?? '',
      isDynamic: json['isDynamic'] ?? false,
      variations: json['variations'],
    );
  }
}

class AccessibilityScore {
  final String schemeName;
  final double score;
  final List<String> issues;

  AccessibilityScore({
    required this.schemeName,
    required this.score,
    required this.issues,
  });

  factory AccessibilityScore.fromJson(Map<String, dynamic> json) {
    return AccessibilityScore(
      schemeName: json['schemeName'] ?? '',
      score: (json['score'] ?? 0.0).toDouble(),
      issues: List<String>.from(json['issues'] ?? []),
    );
  }
}

class CurrentSchemeAnalysis {
  final bool hasPrimary;
  final bool hasSecondary;
  final bool hasAccent;
  final double consistency;
  final String mood;

  CurrentSchemeAnalysis({
    required this.hasPrimary,
    required this.hasSecondary,
    required this.hasAccent,
    required this.consistency,
    required this.mood,
  });

  factory CurrentSchemeAnalysis.fromJson(Map<String, dynamic> json) {
    return CurrentSchemeAnalysis(
      hasPrimary: json['hasPrimary'] ?? false,
      hasSecondary: json['hasSecondary'] ?? false,
      hasAccent: json['hasAccent'] ?? false,
      consistency: (json['consistency'] ?? 0.0).toDouble(),
      mood: json['mood'] ?? '',
    );
  }
}

class TypographySuggestions {
  final List<FontPairing> fontPairings;
  final SizingRecommendations sizingRecommendations;
  final double readabilityScore;

  TypographySuggestions({
    required this.fontPairings,
    required this.sizingRecommendations,
    required this.readabilityScore,
  });

  factory TypographySuggestions.fromJson(Map<String, dynamic> json) {
    return TypographySuggestions(
      fontPairings: (json['fontPairings'] as List?)
          ?.map((f) => FontPairing.fromJson(f))
          .toList() ?? [],
      sizingRecommendations: SizingRecommendations.fromJson(json['sizingRecommendations']),
      readabilityScore: (json['readabilityScore'] ?? 0.0).toDouble(),
    );
  }
}

class FontPairing {
  final String name;
  final String heading;
  final String body;
  final String description;
  final List<String> characteristics;

  FontPairing({
    required this.name,
    required this.heading,
    required this.body,
    required this.description,
    required this.characteristics,
  });

  factory FontPairing.fromJson(Map<String, dynamic> json) {
    return FontPairing(
      name: json['name'] ?? '',
      heading: json['heading'] ?? '',
      body: json['body'] ?? '',
      description: json['description'] ?? '',
      characteristics: List<String>.from(json['characteristics'] ?? []),
    );
  }
}

class SizingRecommendations {
  final FontSize heading;
  final FontSize subheading;
  final FontSize body;
  final FontSize caption;

  SizingRecommendations({
    required this.heading,
    required this.subheading,
    required this.body,
    required this.caption,
  });

  factory SizingRecommendations.fromJson(Map<String, dynamic> json) {
    return SizingRecommendations(
      heading: FontSize.fromJson(json['heading']),
      subheading: FontSize.fromJson(json['subheading']),
      body: FontSize.fromJson(json['body']),
      caption: FontSize.fromJson(json['caption']),
    );
  }
}

class FontSize {
  final double min;
  final double max;
  final double recommended;

  FontSize({
    required this.min,
    required this.max,
    required this.recommended,
  });

  factory FontSize.fromJson(Map<String, dynamic> json) {
    return FontSize(
      min: (json['min'] ?? 0.0).toDouble(),
      max: (json['max'] ?? 0.0).toDouble(),
      recommended: (json['recommended'] ?? 0.0).toDouble(),
    );
  }
}
