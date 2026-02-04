import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/WidgetProvider.dart';
import '../../../models/widget_model.dart';
import '../../../widgets/ai_suggestion_panel.dart';
import '../../../widgets/ui_design_panel.dart';
import 'package:uuid/uuid.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Widget Palette',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Tabs
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.widgets),
              text: 'Widgets',
            ),
            Tab(
              icon: Icon(Icons.lightbulb),
              text: 'AI Suggestions',
            ),
            Tab(
              icon: Icon(Icons.design_services),
              text: 'UI Design',
            ),
          ],
        ),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildWidgetsTab(),
              const AISuggestionPanel(),
              const UIDesignPanel(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetsTab() {
    final widgetTypes = [
      {'type': 'Container', 'icon': Icons.crop_square, 'color': Colors.blue},
      {'type': 'Text', 'icon': Icons.text_fields, 'color': Colors.green},
      {'type': 'Button', 'icon': Icons.smart_button, 'color': Colors.orange},
      {'type': 'Image', 'icon': Icons.image, 'color': Colors.purple},
      {'type': 'Card', 'icon': Icons.credit_card, 'color': Colors.teal},
      {'type': 'Row', 'icon': Icons.view_week, 'color': Colors.indigo},
      {'type': 'Column', 'icon': Icons.view_column, 'color': Colors.pink},
      {'type': 'ListView', 'icon': Icons.list, 'color': Colors.cyan},
      {'type': 'TextField', 'icon': Icons.input, 'color': Colors.amber},
      {'type': 'AppBar', 'icon': Icons.web_asset, 'color': Colors.deepOrange},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widgetTypes.length,
      itemBuilder: (context, index) {
        final widget = widgetTypes[index];
        return _WidgetPaletteItem(
          type: widget['type'] as String,
          icon: widget['icon'] as IconData,
          color: widget['color'] as Color,
        );
      },
    );
  }
}

class _WidgetPaletteItem extends StatelessWidget {
  final String type;
  final IconData icon;
  final Color color;

  const _WidgetPaletteItem({
    required this.type,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: type,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 120,
          height: 80,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 4),
              Text(
                type,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCard(context),
      ),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _addWidget(context);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(
                type,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addWidget(BuildContext context) {
    final provider = context.read<WidgetProvider>();
    final uuid = const Uuid();

    final newWidget = WidgetModel(
      id: uuid.v4(),
      type: type,
      properties: _getDefaultProperties(type),
      position: Offset(100, 100),
    );

    provider.addWidget(newWidget);
  }

  Map<String, dynamic> _getDefaultProperties(String type) {
    switch (type) {
      case 'Text':
        return {
          'text': 'Text Widget',
          'fontSize': 16.0,
          'color': '#000000',
          'fontWeight': 'normal',
        };
      case 'Button':
        return {
          'text': 'Button',
          'backgroundColor': '#2196F3',
          'color': '#FFFFFF',
          'fontSize': 16.0,
        };
      case 'Container':
        return {
          'width': 200.0,
          'height': 100.0,
          'backgroundColor': '#E3F2FD',
          'borderRadius': 8.0,
        };
      case 'Image':
        return {
          'width': 200.0,
          'height': 200.0,
          'image': 'https://via.placeholder.com/200',
        };
      case 'TextField':
        return {
          'hint': 'Enter text',
          'fontSize': 16.0,
        };
      case 'AppBar':
        return {
          'title': 'App Bar',
          'backgroundColor': '#2196F3',
          'color': '#FFFFFF',
        };
      default:
        return {
          'backgroundColor': '#FFFFFF',
        };
    }
  }
}