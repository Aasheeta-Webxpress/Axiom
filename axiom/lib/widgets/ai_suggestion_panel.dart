import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:axiom/services/widget_suggestion_service.dart';
import 'package:axiom/providers/ProjectProvider.dart';
import 'package:axiom/providers/WidgetProvider.dart';
import 'package:axiom/models/widget_model.dart';

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
        'type': 'unknown', // ProjectModel doesn't have type field
        'widgetCount': project.screens.isNotEmpty ? project.screens.first.widgets.length : 0,
      };

      final existingWidgets = project.screens.isNotEmpty 
        ? project.screens.first.widgets.map((w) => {
            'id': w.id,
            'type': w.type,
            'properties': w.properties,
          }).toList()
        : [];

      final suggestions = await WidgetSuggestionService.getWidgetSuggestions(
        projectContext: projectContext,
        existingWidgets: existingWidgets.cast<Map<String, dynamic>>(),
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
              prefixIcon: const Icon(Icons.search),
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
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No suggestions available'),
                        Text(
                          'Start adding widgets to get AI suggestions',
                          style: TextStyle(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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
              _buildSuggestionCard(suggestion)
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
              _buildLayoutSuggestionCard(layout)
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
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
    final widgetProvider = context.read<WidgetProvider>();
    final projectProvider = context.read<ProjectProvider>();
    
    final newWidget = WidgetModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: suggestion.widgetType,
      properties: {
        ...suggestion.properties,
        'label': suggestion.properties['label'] ?? 'New ' + suggestion.widgetType,
        'hint': suggestion.properties['hint'] ?? '',
      },
      position: Offset(
        suggestion.position['suggestedX']?.toDouble() ?? 100.0,
        suggestion.position['suggestedY']?.toDouble() ?? 100.0,
      ),
    );

    widgetProvider.addWidget(newWidget);
    
    // Also save to project if needed
    if (projectProvider.currentProject != null && projectProvider.currentProject!.screens.isNotEmpty) {
      final currentScreen = projectProvider.currentProject!.screens.first;
      currentScreen.widgets.add(newWidget);
    }
    
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
