# 🎯 Feature #3: AI Widget Suggestions

## 🎯 **Overview**
Implement AI-powered widget suggestions that recommend relevant UI components based on project context, existing widgets, and user intent. This makes the no-code experience more intuitive and helps users discover useful widgets.

## ⏱️ **Implementation Time**: 2 hours

## 🛠️ **Files to Modify**

### Backend Files:
- `axiomBackend/src/services/widgetSuggestionService.js` (NEW)
- `axiomBackend/src/routes/widgetSuggestionRoutes.js` (NEW)

### Frontend Files:
- `axiom/lib/services/widget_suggestion_service.dart` (NEW)
- `axiom/lib/widgets/widget_palette.dart` (MODIFY)
- `axiom/lib/widgets/ai_suggestion_panel.dart` (NEW)

---

## 🚀 **Step 1: Backend Widget Suggestion Service**

### Create AI Widget Suggestion Service
```javascript
// axiomBackend/src/services/widgetSuggestionService.js
import openaiClient from './openaiClient.js';

class WidgetSuggestionService {
  async getWidgetSuggestions(projectContext, existingWidgets, userIntent = '') {
    const prompt = `
You are a UI/UX expert for a no-code platform. Suggest the most relevant widgets for this project context.

Project Context:
${JSON.stringify(projectContext, null, 2)}

Existing Widgets:
${existingWidgets.map(w => `- ${w.type}: ${w.properties?.label || w.id}`).join('\n')}

User Intent: "${userIntent}"

Available Widget Types:
- TextField: Text input fields
- Button: Clickable buttons
- Label: Text labels and titles
- Dropdown: Selection dropdowns
- Checkbox: Boolean selection
- Radio: Single choice selection
- Image: Image display
- ListView: Scrollable lists
- Card: Container widgets
- Container: Layout containers
- DatePicker: Date selection
- TimePicker: Time selection
- Rating: Star rating widget
- ProgressBar: Progress indication
- Switch: Toggle switches
- Slider: Numeric range selection

Return a JSON object with:
{
  "suggestions": [
    {
      "widgetType": "WidgetType",
      "reason": "Why this widget is recommended",
      "priority": "high|medium|low",
      "properties": {
        "label": "Suggested label",
        "hint": "Suggested hint text",
        "fieldType": "text|email|number|etc",
        "required": true|false
      },
      "position": {
        "suggestedX": 100,
        "suggestedY": 200
      }
    }
  ],
  "layoutSuggestions": [
    {
      "type": "vertical|horizontal|grid",
      "description": "Layout recommendation",
      "widgets": ["widget1", "widget2"]
    }
  ],
  "nextSteps": [
    "Suggested next action 1",
    "Suggested next action 2"
  ]
}

Consider:
1. Project type (e-commerce, blog, contact form, etc.)
2. Existing widgets and what's missing
3. Common UI patterns for this type of project
4. User intent if provided
5. Best practices for user experience

Only return valid JSON, no explanations.
`;

    try {
      const response = await openaiClient.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.3,
      });

      const content = response.choices[0].message.content;
      return JSON.parse(content);
    } catch (error) {
      console.error('Widget Suggestions AI Error:', error);
      return this.getFallbackSuggestions(projectContext, existingWidgets);
    }
  }

  getFallbackSuggestions(projectContext, existingWidgets) {
    const existingTypes = existingWidgets.map(w => w.type);
    const commonWidgets = [
      { type: 'Button', reason: 'Every form needs a submit button' },
      { type: 'Label', reason: 'Add descriptive labels for better UX' },
      { type: 'TextField', reason: 'Collect user input' },
    ];

    const suggestions = commonWidgets
      .filter(w => !existingTypes.includes(w.type))
      .slice(0, 3)
      .map(w => ({
        widgetType: w.type,
        reason: w.reason,
        priority: 'medium',
        properties: {
          label: `New ${w.type}`,
          hint: `Enter ${w.type.toLowerCase()} information`,
        },
        position: { suggestedX: 50, suggestedY: 50 }
      }));

    return {
      suggestions,
      layoutSuggestions: [],
      nextSteps: ['Add more widgets to your canvas']
    };
  }

  async getWidgetOptimization(widgets, projectContext) {
    const prompt = `
Analyze this widget configuration and suggest optimizations:

Widgets:
${JSON.stringify(widgets, null, 2)}

Project Context:
${JSON.stringify(projectContext, null, 2)}

Suggest improvements for:
1. Widget properties and settings
2. Layout and positioning
3. User experience
4. Accessibility
5. Performance

Return a JSON object with:
{
  "optimizations": [
    {
      "widgetId": "widget_id_or_null",
      "type": "property|layout|accessibility|performance",
      "suggestion": "Specific improvement suggestion",
      "priority": "high|medium|low",
      "before": "Current state description",
      "after": "Improved state description"
    }
  ],
  "accessibilityIssues": [
    {
      "widgetId": "widget_id",
      "issue": "Description of accessibility issue",
      "solution": "How to fix it"
    }
  ],
  "performanceTips": [
    "Performance optimization tip 1",
    "Performance optimization tip 2"
  ]
}

Only return valid JSON, no explanations.
`;

    try {
      const response = await openaiClient.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.2,
      });

      const content = response.choices[0].message.content;
      return JSON.parse(content);
    } catch (error) {
      console.error('Widget Optimization AI Error:', error);
      return {
        optimizations: [],
        accessibilityIssues: [],
        performanceTips: ['Consider reducing the number of widgets for better performance']
      };
    }
  }

  async getProjectTypeSuggestions(projectName, projectDescription) {
    const prompt = `
Analyze this project information and suggest the project type and common widgets:

Project Name: "${projectName}"
Project Description: "${projectDescription}"

Return a JSON object with:
{
  "projectType": "e-commerce|blog|portfolio|contact-form|dashboard|survey|registration|other",
  "confidence": 0.0-1.0,
  "commonWidgets": [
    {
      "widgetType": "WidgetType",
      "purpose": "Why this widget is commonly used",
      "properties": {
        "label": "Suggested label",
        "fieldType": "suggested_field_type"
      }
    }
  ],
  "layoutPattern": "single-column|two-column|grid|sidebar|tabs",
  "colorScheme": "professional|colorful|minimal|dark|light"
}

Only return valid JSON, no explanations.
`;

    try {
      const response = await openaiClient.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.3,
      });

      const content = response.choices[0].message.content;
      return JSON.parse(content);
    } catch (error) {
      console.error('Project Type AI Error:', error);
      return {
        projectType: 'other',
        confidence: 0.5,
        commonWidgets: [
          { widgetType: 'Label', purpose: 'Add titles and descriptions' },
          { widgetType: 'TextField', purpose: 'Collect user input' },
          { widgetType: 'Button', purpose: 'Enable user actions' }
        ],
        layoutPattern: 'single-column',
        colorScheme: 'professional'
      };
    }
  }
}

export default new WidgetSuggestionService();
```

### Create Widget Suggestion Routes
```javascript
// axiomBackend/src/routes/widgetSuggestionRoutes.js
import { Router } from 'express';
import widgetSuggestionService from '../services/widgetSuggestionService.js';

const router = Router();

// Get widget suggestions
router.post('/suggestions', async (req, res) => {
  try {
    const { projectContext, existingWidgets, userIntent } = req.body;
    
    if (!projectContext) {
      return res.status(400).json({ 
        error: 'Project context is required' 
      });
    }

    const suggestions = await widgetSuggestionService.getWidgetSuggestions(
      projectContext,
      existingWidgets || [],
      userIntent || ''
    );
    
    res.json({
      success: true,
      data: suggestions
    });
  } catch (error) {
    console.error('Widget Suggestions Error:', error);
    res.status(500).json({ 
      error: 'Failed to get widget suggestions',
      message: error.message 
    });
  }
});

// Get widget optimizations
router.post('/optimizations', async (req, res) => {
  try {
    const { widgets, projectContext } = req.body;
    
    if (!widgets) {
      return res.status(400).json({ 
        error: 'Widgets data is required' 
      });
    }

    const optimizations = await widgetSuggestionService.getWidgetOptimization(
      widgets,
      projectContext || {}
    );
    
    res.json({
      success: true,
      data: optimizations
    });
  } catch (error) {
    console.error('Widget Optimizations Error:', error);
    res.status(500).json({ 
      error: 'Failed to get widget optimizations',
      message: error.message 
    });
  }
});

// Get project type suggestions
router.post('/project-type', async (req, res) => {
  try {
    const { projectName, projectDescription } = req.body;
    
    if (!projectName) {
      return res.status(400).json({ 
        error: 'Project name is required' 
      });
    }

    const typeSuggestions = await widgetSuggestionService.getProjectTypeSuggestions(
      projectName,
      projectDescription || ''
    );
    
    res.json({
      success: true,
      data: typeSuggestions
    });
  } catch (error) {
    console.error('Project Type Suggestions Error:', error);
    res.status(500).json({ 
      error: 'Failed to get project type suggestions',
      message: error.message 
    });
  }
});

export default router;
```

### Update Server to Include Widget Suggestion Routes
```javascript
// In axiomBackend/src/server.js, add:
import widgetSuggestionRoutes from './routes/widgetSuggestionRoutes.js';

// Add this line with other routes:
app.use('/api/widget-suggestions', widgetSuggestionRoutes);
```

---

## 📱 **Step 2: Frontend Widget Suggestion Service**

### Create Widget Suggestion Service for Flutter
```dart
// axiom/lib/services/widget_suggestion_service.dart
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
    required this.accessibilityIssues,
    required this.performanceTips,
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
```

---

## 🎨 **Step 3: AI Suggestion Panel Widget**

### Create AI Suggestion Panel
```dart
// axiom/lib/widgets/ai_suggestion_panel.dart
import 'package:flutter/material.dart';
import 'package:axiom/services/widget_suggestion_service.dart';
import 'package:axiom/models/widget_model.dart';
import 'package:provider/provider.dart';
import 'package:axiom/providers/ProjectProvider.dart';

class AISuggestionPanel extends StatefulWidget {
  const AISuggestionPanel({super.key});

  @override
  State<AISuggestionPanel> createState() => _AISuggestionPanelState();
}

class _AISuggestionPanelState extends State<AISuggestionPanel> {
  bool _isLoading = false;
  WidgetSuggestions? _suggestions;
  List<String> _nextSteps = [];
  String _userIntent = '';

  Future<void> _loadSuggestions() async {
    final projectProvider = context.read<ProjectProvider>();
    final project = projectProvider.currentProject;
    
    if (project == null) return;

    setState(() => _isLoading = true);

    try {
      final projectContext = {
        'name': project.name,
        'description': project.description,
        'type': project.type ?? 'unknown',
        'widgetCount': project.widgets.length,
      };

      final existingWidgets = project.widgets.map((w) => {
        'id': w.id,
        'type': w.type,
        'properties': w.properties,
      }).toList();

      final suggestions = await WidgetSuggestionService.getWidgetSuggestions(
        projectContext: projectContext,
        existingWidgets: existingWidgets,
        userIntent: _userIntent,
      );

      setState(() {
        _suggestions = suggestions;
        _nextSteps = suggestions.nextSteps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load suggestions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSuggestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'AI Suggestions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadSuggestions,
                icon: _isLoading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
                tooltip: 'Refresh Suggestions',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // User Intent Input
          TextField(
            decoration: const InputDecoration(
              labelText: 'What are you trying to build?',
              hintText: 'e.g., A contact form with name and email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              _userIntent = value;
            },
            onSubmitted: (_) => _loadSuggestions(),
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _suggestions != null
                ? _buildSuggestionsContent()
                : const Center(
                    child: Text('No suggestions available'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Widget Suggestions
          if (_suggestions!.suggestions.isNotEmpty) ...[
            const Text(
              'Recommended Widgets:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._suggestions!.suggestions.map((suggestion) => 
              _buildSuggestionCard(suggestion),
            ),
            const SizedBox(height: 16),
          ],

          // Layout Suggestions
          if (_suggestions!.layoutSuggestions.isNotEmpty) ...[
            const Text(
              'Layout Suggestions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._suggestions!.layoutSuggestions.map((layout) => 
              _buildLayoutSuggestionCard(layout),
            ),
            const SizedBox(height: 16),
          ],

          // Next Steps
          if (_nextSteps.isNotEmpty) ...[
            const Text(
              'Next Steps:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._nextSteps.map((step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_right, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(child: Text(step)),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(WidgetSuggestion suggestion) {
    final priorityColor = _getPriorityColor(suggestion.priority);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: priorityColor),
                  ),
                  child: Text(
                    suggestion.widgetType,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _addSuggestedWidget(suggestion),
                  icon: const Icon(Icons.add, color: Colors.green),
                  tooltip: 'Add this widget',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              suggestion.reason,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            if (suggestion.properties.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Properties: ${suggestion.properties.keys.join(', ')}',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutSuggestionCard(LayoutSuggestion layout) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  layout.type.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              layout.description,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _addSuggestedWidget(WidgetSuggestion suggestion) {
    final projectProvider = context.read<ProjectProvider>();
    
    final newWidget = WidgetModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: suggestion.widgetType,
      properties: {
        ...suggestion.properties,
        'label': suggestion.properties['label'] ?? 'New ${suggestion.widgetType}',
        'hint': suggestion.properties['hint'] ?? '',
      },
      position: Offset(
        suggestion.position['suggestedX']?.toDouble() ?? 100.0,
        suggestion.position['suggestedY']?.toDouble() ?? 100.0,
      ),
    );

    projectProvider.addWidget(newWidget);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${suggestion.widgetType} added successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Refresh suggestions after adding widget
    Future.delayed(const Duration(milliseconds: 500), () {
      _loadSuggestions();
    });
  }
}
```

---

## 🔧 **Step 4: Update Widget Palette**

### Enhance Widget Palette with AI Suggestions
```dart
// In axiom/lib/widgets/widget_palette.dart, add AI suggestions tab:

class WidgetPalette extends StatefulWidget {
  const WidgetPalette({super.key});

  @override
  State<WidgetPalette> createState() => _WidgetPaletteState();
}

class _WidgetPaletteState extends State<WidgetPalette> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.widgets), text: 'Widgets'),
            Tab(icon: Icon(Icons.lightbulb), text: 'AI Suggestions'),
          ],
        ),
        
        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildWidgetsTab(),
              _buildAISuggestionsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetsTab() {
    // Your existing widget list code here
    return ListView(
      children: [
        _buildWidgetCategory('Input', [
          _buildWidgetTile('TextField', Icons.text_fields),
          _buildWidgetTile('Dropdown', Icons.arrow_drop_down),
          _buildWidgetTile('Checkbox', Icons.check_box),
          _buildWidgetTile('Radio', Icons.radio_button_checked),
        ]),
        _buildWidgetCategory('Display', [
          _buildWidgetTile('Label', Icons.label),
          _buildWidgetTile('Image', Icons.image),
          _buildWidgetTile('Card', Icons.card_membership),
        ]),
        _buildWidgetCategory('Layout', [
          _buildWidgetTile('Container', Icons.crop_square),
          _buildWidgetTile('ListView', Icons.list),
        ]),
      ],
    );
  }

  Widget _buildAISuggestionsTab() {
    return const AISuggestionPanel();
  }

  Widget _buildWidgetCategory(String title, List<Widget> widgets) {
    return ExpansionTile(
      title: Text(title),
      children: widgets,
    );
  }

  Widget _buildWidgetTile(String type, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(type),
      onTap: () {
        // Your existing widget creation logic
        _createWidget(type);
      },
    );
  }

  void _createWidget(String type) {
    final projectProvider = context.read<ProjectProvider>();
    
    final newWidget = WidgetModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      properties: {
        'label': 'New $type',
        'hint': 'Enter $type information',
      },
      position: const Offset(50, 50),
    );

    projectProvider.addWidget(newWidget);
  }
}
```

---

## 🧪 **Step 5: Testing**

### Test AI Widget Suggestions:

1. **Start Backend Server**
   ```bash
   cd axiomBackend
   npm run dev
   ```

2. **Start Flutter App**
   ```bash
   cd axiom
   flutter run
   ```

3. **Test Widget Suggestions**
   - Open the editor
   - Go to Widget Palette
   - Click "AI Suggestions" tab
   - Try different intents in the search box:
     - "contact form"
     - "user registration"
     - "product catalog"
   - Click the refresh button to reload suggestions

4. **Test Adding Suggested Widgets**
   - Click the "+" button on suggested widgets
   - Verify widgets are added to canvas
   - Check if properties are applied correctly

5. **Test Different Project Types**
   - Create projects with different names/descriptions
   - Check if suggestions adapt to project context

### Test Cases to Try:
- **Contact Form**: Should suggest TextField, Button, Label
- **E-commerce**: Should suggest Image, Card, Button
- **Survey**: Should suggest Radio, Checkbox, TextField
- **Dashboard**: Should suggest ListView, Card, ProgressBar

---

## 🐛 **Common Issues & Solutions**

### Issue 1: Suggestions Not Loading
**Solution**: Check backend logs and OpenAI API key

### Issue 2: Widget Addition Fails
**Solution**: Verify ProjectProvider and WidgetModel integration

### Issue 3: Suggestions Not Context-Aware
**Solution**: Ensure project context is properly sent to AI

### Issue 4: Performance Issues
**Solution**: Implement caching for suggestions

---

## ✅ **Success Criteria**

- [ ] AI suggests relevant widgets based on project context
- [ ] Users can add suggested widgets with one click
- [ ] Suggestions adapt to user intent input
- [ ] Layout suggestions are helpful
- [ ] Next steps guide users effectively
- [ ] Performance is acceptable for real-time suggestions

---

## 🎉 **Next Steps**

Once this feature is working, proceed to **Feature #4: Smart UI Design Assistant** by opening `guides/04_smart_ui_design_assistant.md`.

**Excellent! You've added AI-powered widget suggestions to your no-code platform!** 🎯✨
