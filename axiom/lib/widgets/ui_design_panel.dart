import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:axiom/services/ui_design_service.dart' as ui_service;
import 'package:axiom/providers/WidgetProvider.dart';
import 'package:axiom/providers/ProjectProvider.dart';
import 'package:axiom/models/widget_model.dart';

class UIDesignPanel extends StatefulWidget {
  const UIDesignPanel({super.key});

  @override
  State<UIDesignPanel> createState() => _UIDesignPanelState();
}

class _UIDesignPanelState extends State<UIDesignPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  // Layout suggestions
  ui_service.LayoutSuggestions? _layoutSuggestions;
  
  // Color schemes
  ui_service.ColorSchemeSuggestions? _colorSchemes;
  
  // Typography
  ui_service.TypographySuggestions? _typographySuggestions;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllSuggestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllSuggestions() async {
    await Future.wait([
      _loadLayoutSuggestions(),
      _loadColorSchemes(),
      _loadTypographySuggestions(),
    ]);
  }

  Future<void> _loadLayoutSuggestions() async {
    final widgetProvider = context.read<WidgetProvider>();
    final projectProvider = context.read<ProjectProvider>();
    
    setState(() => _isLoading = true);

    try {
      final widgets = widgetProvider.widgets.map((w) => {
        'id': w.id,
        'type': w.type,
        'position': {'dx': w.position.dx, 'dy': w.position.dy},
        'properties': w.properties,
      }).toList();

      final canvasSize = {
        'width': 800.0,
        'height': 600.0,
      };

      final projectType = _getProjectType(projectProvider.currentProject?.name ?? '');

      final suggestions = await ui_service.UIDesignService.getLayoutSuggestions(
        widgets: widgets,
        canvasSize: canvasSize,
        projectType: projectType,
      );

      setState(() {
        _layoutSuggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load layout suggestions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadColorSchemes() async {
    final projectProvider = context.read<ProjectProvider>();
    
    try {
      final projectType = _getProjectType(projectProvider.currentProject?.name ?? '');

      final schemes = await ui_service.UIDesignService.getColorSchemeSuggestions(
        projectType: projectType,
      );

      setState(() {
        _colorSchemes = schemes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load color schemes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadTypographySuggestions() async {
    final projectProvider = context.read<ProjectProvider>();
    
    try {
      final projectType = _getProjectType(projectProvider.currentProject?.name ?? '');

      final typography = await ui_service.UIDesignService.getTypographySuggestions(
        projectType: projectType,
      );

      setState(() {
        _typographySuggestions = typography;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load typography suggestions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getProjectType(String projectName) {
    final name = projectName.toLowerCase();
    if (name.contains('dashboard')) return 'dashboard';
    if (name.contains('ecommerce') || name.contains('shop')) return 'ecommerce';
    if (name.contains('blog') || name.contains('post')) return 'blog';
    if (name.contains('survey')) return 'survey';
    return 'general';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.design_services, color: Colors.purple),
              const SizedBox(width: 8),
              const Text(
                'UI Design Assistant',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadAllSuggestions,
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

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.grid_view),
                text: 'Layout',
              ),
              Tab(
                icon: Icon(Icons.palette),
                text: 'Colors',
              ),
              Tab(
                icon: Icon(Icons.text_fields),
                text: 'Typography',
              ),
            ],
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLayoutTab(),
                _buildColorsTab(),
                _buildTypographyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutTab() {
    if (_layoutSuggestions == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Layout Analysis
          _buildLayoutAnalysis(),
          const SizedBox(height: 16),

          // Suggestions
          _buildLayoutSuggestions(),
          const SizedBox(height: 16),

          // Auto Layouts
          _buildAutoLayouts(),
        ],
      ),
    );
  }

  Widget _buildLayoutAnalysis() {
    final analysis = _layoutSuggestions!.layoutAnalysis;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Layout Analysis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Widgets',
                    analysis.widgetCount.toString(),
                    Icons.widgets,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    'Density',
                    '${(analysis.density * 100).toStringAsFixed(1)}%',
                    Icons.density_medium,
                    analysis.density > 0.7 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Alignment',
                    '${(analysis.alignment.score * 100).toStringAsFixed(0)}%',
                    Icons.align_horizontal_center,
                    analysis.alignment.score > 0.7 ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    'Hierarchy',
                    '${(analysis.hierarchy.clarity * 100).toStringAsFixed(0)}%',
                    Icons.format_size,
                    analysis.hierarchy.clarity > 0.7 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutSuggestions() {
    final suggestions = _layoutSuggestions!.suggestions;
    
    if (suggestions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No layout suggestions available'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Improvement Suggestions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...suggestions.map((suggestion) => Card(
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
                        color: _getPriorityColor(suggestion.priority).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getPriorityColor(suggestion.priority)),
                      ),
                      child: Text(
                        suggestion.priority.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getPriorityColor(suggestion.priority),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion.suggestion,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  suggestion.action,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Impact: ${suggestion.impact}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildAutoLayouts() {
    final layouts = _layoutSuggestions!.autoLayouts;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Auto Layouts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...layouts.map((layout) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.purple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        layout.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(layout.suitability * 100).toStringAsFixed(0)}% fit',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  layout.description,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _applyAutoLayout(layout),
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Apply Layout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildColorsTab() {
    if (_colorSchemes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Color Picker
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Custom Color Generator',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _generateCustomColorScheme,
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: const Text('Generate Random', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _refreshColorSchemes,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Refresh', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _testColorApplication,
                          icon: const Icon(Icons.science, size: 16),
                          label: const Text('Test Apply', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Recommended Color Schemes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._colorSchemes!.recommendedSchemes.map((scheme) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        scheme.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (scheme.isDynamic == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'DYNAMIC',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: scheme.accessibility == 'AAA compliant' 
                            ? Colors.green.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          scheme.accessibility,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: scheme.accessibility == 'AAA compliant' 
                              ? Colors.green
                              : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    scheme.description,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  
                  // Main color swatches
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Main Colors:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildColorSwatch('Primary', scheme.primary),
                          _buildColorSwatch('Secondary', scheme.secondary),
                          _buildColorSwatch('Accent', scheme.accent),
                        ],
                      ),
                    ],
                  ),
                  
                  // Dynamic variations if available
                  if (scheme.variations != null) ...[
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dynamic Variations:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _buildColorSwatch('Light', scheme.variations!['light'] ?? '#FFFFFF'),
                            _buildColorSwatch('Dark', scheme.variations!['dark'] ?? '#000000'),
                          ],
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _applyColorScheme(scheme),
                      icon: const Icon(Icons.palette),
                      label: Text(scheme.isDynamic == true ? 'Apply Dynamic Scheme' : 'Apply Scheme'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.isDynamic == true ? Colors.purple : Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(String label, String color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: _parseColor(color),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildTypographyTab() {
    if (_typographySuggestions == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Font Pairings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._typographySuggestions!.fontPairings.map((pairing) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pairing.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pairing.description,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Heading: ${pairing.heading}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Body: ${pairing.body}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Characteristics:', style: TextStyle(fontWeight: FontWeight.w600)),
                            ...pairing.characteristics.map((char) => Text(
                              '• $char',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _applyFontPairing(pairing),
                      icon: const Icon(Icons.text_fields),
                      label: const Text('Apply Fonts'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: 16),
          _buildSizingRecommendations(),
        ],
      ),
    );
  }

  Widget _buildSizingRecommendations() {
    final sizing = _typographySuggestions!.sizingRecommendations;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sizing Recommendations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSizeRow('Heading', sizing.heading),
            _buildSizeRow('Subheading', sizing.subheading),
            _buildSizeRow('Body', sizing.body),
            _buildSizeRow('Caption', sizing.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeRow(String label, ui_service.FontSize size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text('${size.min}px'),
          const Text(' - '),
          Text('${size.max}px'),
          const Text(' ('),
          Text(
            '${size.recommended}px',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const Text(')'),
        ],
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

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  void _applyAutoLayout(ui_service.AutoLayout layout) {
    final widgetProvider = context.read<WidgetProvider>();
    
    for (final position in layout.positions) {
      final widget = widgetProvider.widgets.firstWhere(
        (w) => w.id == position.id,
        orElse: () => widgetProvider.widgets.first,
      );
      
      final updatedWidget = WidgetModel(
        id: widget.id,
        type: widget.type,
        properties: widget.properties,
        position: Offset(position.x, position.y),
      );
      
      widgetProvider.updateWidget(updatedWidget);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${layout.name} applied successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _applyColorScheme(ui_service.UIColorScheme scheme) {
    final widgetProvider = context.read<WidgetProvider>();
    final projectProvider = context.read<ProjectProvider>();
    
    // Apply colors to existing widgets
    final widgets = widgetProvider.widgets;
    
    print('🎨 Applying color scheme: ${scheme.name}');
    print('🎨 Available widgets: ${widgets.length}');
    
    for (final widget in widgets) {
      Map<String, dynamic> updatedProperties = Map.from(widget.properties);
      
      print('🎨 Processing widget: ${widget.type} - Current props: ${widget.properties}');
      
      // Apply colors based on widget type
      switch (widget.type) {
        case 'Text':
          updatedProperties['color'] = scheme.text;
          print('🎨 Applied text color: ${scheme.text}');
          break;
        case 'Button':
          updatedProperties['backgroundColor'] = scheme.primary;
          updatedProperties['color'] = scheme.background;
          print('🎨 Applied button colors: bg=${scheme.primary}, text=${scheme.background}');
          break;
        case 'Container':
          updatedProperties['backgroundColor'] = scheme.background;
          if (scheme.secondary != null) {
            updatedProperties['borderColor'] = scheme.secondary;
          }
          print('🎨 Applied container colors: bg=${scheme.background}, border=${scheme.secondary}');
          break;
        case 'Card':
          updatedProperties['backgroundColor'] = scheme.background;
          if (scheme.secondary != null) {
            updatedProperties['borderColor'] = scheme.secondary;
          }
          print('🎨 Applied card colors: bg=${scheme.background}, border=${scheme.secondary}');
          break;
        case 'TextField':
          updatedProperties['backgroundColor'] = scheme.background;
          if (scheme.secondary != null) {
            updatedProperties['borderColor'] = scheme.secondary;
          }
          updatedProperties['textColor'] = scheme.text;
          print('🎨 Applied textfield colors: bg=${scheme.background}, border=${scheme.secondary}, text=${scheme.text}');
          break;
        case 'AppBar':
          updatedProperties['backgroundColor'] = scheme.primary;
          updatedProperties['color'] = scheme.background;
          print('🎨 Applied appbar colors: bg=${scheme.primary}, text=${scheme.background}');
          break;
      }
      
      // Update the widget
      final updatedWidget = WidgetModel(
        id: widget.id,
        type: widget.type,
        properties: updatedProperties,
        position: widget.position,
      );
      
      widgetProvider.updateWidget(updatedWidget);
      print('🎨 Updated widget ${widget.id} with new properties');
    }
    
    // Store the color scheme in project for persistence
    if (projectProvider.currentProject != null) {
      final project = projectProvider.currentProject!;
      // You could add color scheme to project model here
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${scheme.name} applied to ${widgets.length} widgets!'),
        backgroundColor: _parseColor(scheme.primary),
        duration: const Duration(seconds: 3),
      ),
    );
    
    print('🎨 Color scheme application completed!');
  }

  void _applyFontPairing(ui_service.FontPairing pairing) {
    final widgetProvider = context.read<WidgetProvider>();
    final widgets = widgetProvider.widgets;
    
    int updatedCount = 0;
    
    print('🔤 Applying font pairing: ${pairing.name}');
    print('🔤 Available widgets: ${widgets.length}');
    
    for (final widget in widgets) {
      Map<String, dynamic> updatedProperties = Map.from(widget.properties);
      
      print('🔤 Processing widget: ${widget.type} - Current props: ${widget.properties}');
      
      // Apply fonts based on widget type
      switch (widget.type) {
        case 'Text':
          updatedProperties['fontFamily'] = pairing.heading;
          updatedProperties['fontSize'] = updatedProperties['fontSize'] ?? 16.0;
          print('🔤 Applied text font: ${pairing.heading}');
          break;
        case 'Button':
          updatedProperties['fontFamily'] = pairing.body;
          updatedProperties['fontSize'] = updatedProperties['fontSize'] ?? 14.0;
          print('🔤 Applied button font: ${pairing.body}');
          break;
        case 'TextField':
          updatedProperties['fontFamily'] = pairing.body;
          updatedProperties['fontSize'] = updatedProperties['fontSize'] ?? 16.0;
          print('🔤 Applied textfield font: ${pairing.body}');
          break;
        case 'AppBar':
          updatedProperties['fontFamily'] = pairing.heading;
          updatedProperties['fontSize'] = updatedProperties['fontSize'] ?? 20.0;
          print('🔤 Applied appbar font: ${pairing.heading}');
          break;
      }
      
      // Update the widget
      final updatedWidget = WidgetModel(
        id: widget.id,
        type: widget.type,
        properties: updatedProperties,
        position: widget.position,
      );
      
      widgetProvider.updateWidget(updatedWidget);
      updatedCount++;
      print('🔤 Updated widget ${widget.id} with new font');
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${pairing.name} fonts applied to $updatedCount widgets!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
    print('🔤 Font pairing application completed!');
  }

  Future<void> _generateCustomColorScheme() async {
    final projectProvider = context.read<ProjectProvider>();
    final projectType = _getProjectType(projectProvider.currentProject?.name ?? '');
    
    // Generate random existing colors for dynamic generation
    final randomColors = <String, String>{
      'brightness': ((DateTime.now().millisecond % 100) / 100).toString(),
      'background': '#FFFFFF',
      'text': '#212121',
    };
    
    try {
      final schemes = await ui_service.UIDesignService.getColorSchemeSuggestions(
        projectType: projectType,
        existingColors: randomColors,
      );
      
      setState(() {
        _colorSchemes = schemes;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New dynamic color schemes generated!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate custom schemes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshColorSchemes() async {
    await _loadColorSchemes();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Color schemes refreshed!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _testColorApplication() {
    // Create a test color scheme
    final testScheme = ui_service.UIColorScheme(
      name: 'Test Scheme',
      primary: '#FF0000', // Red
      secondary: '#00FF00', // Green
      accent: '#0000FF', // Blue
      background: '#FFFF00', // Yellow
      text: '#000000', // Black
      description: 'Test color scheme for debugging',
      accessibility: 'AA compliant',
      mood: 'test',
      isDynamic: true,
    );
    
    print('🧪 Testing color application with test scheme');
    _applyColorScheme(testScheme);
  }
}
